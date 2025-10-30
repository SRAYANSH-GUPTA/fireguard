import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:developer' as dev;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform, kIsWeb;
import 'package:firebase_core/firebase_core.dart';

import 'package:fireguard/firebase_options.dart';
import 'package:fireguard/services/user_service.dart';
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static bool _interactiveInProgress = false;
  static bool _initialized = false;
  static Future<void> ensureInitialized({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    if (_initialized) return;

    // Ensure Firebase is initialized (defensive in case called very early).
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    clientId ??= _inferPlatformClientId();

    dev.log('[AuthService] Initializing GoogleSignIn (clientId=$clientId, hostedDomain=$hostedDomain)');
    await GoogleSignIn.instance.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
      hostedDomain: hostedDomain,
      nonce: nonce,
    );
    
    try {
      GoogleSignIn.instance.authenticationEvents.listen((event) {
        dev.log('[AuthService] authenticationEvents -> ${event.runtimeType}');
      }, onError: (err, st) {
        dev.log('[AuthService] authenticationEvents error: $err');
        if (err is GoogleSignInException && err.code == GoogleSignInExceptionCode.canceled) {
          dev.log('[AuthService] Hint: If you did not manually cancel, re-check Firebase console SHA-1/SHA-256, google-services.json freshness, and ensure only one authenticate() call.');
        }
      });
    } catch (e) {
      dev.log('[AuthService] Unable to attach authenticationEvents listener: $e');
    }
    _initialized = true;
    dev.log('[AuthService] GoogleSignIn initialized');
  }

  /// Try to infer a suitable client ID from Firebase options (mainly for iOS/macOS).
  static String? _inferPlatformClientId() {
    try {
      if (kIsWeb) {
        return null;
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
          return DefaultFirebaseOptions.ios.iosClientId;
        case TargetPlatform.android:
         
          return null;
        default:
          return null;
      }
    } catch (e) {
      dev.log('[AuthService] Failed inferring clientId: $e');
      return null;
    }
  }
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle({
    String? clientId,
    String? serverClientId,
    String? nonce,
    String? hostedDomain,
  }) async {
    if (_interactiveInProgress) {
      dev.log('[AuthService] signInWithGoogle ignored: interactive authentication already in progress');
      return null;
    }
    _interactiveInProgress = true;
    try {
      await ensureInitialized(
        clientId: clientId,
        serverClientId: serverClientId,
        nonce: nonce,
        hostedDomain: hostedDomain,
      );

      dev.log('[AuthService] Launching Google interactive authenticate()');
      final GoogleSignInAccount account = await GoogleSignIn.instance.authenticate().timeout(
        const Duration(seconds: 40),
        onTimeout: () {
          throw const GoogleSignInException(
            code: GoogleSignInExceptionCode.unknownError,
            description: 'Google Sign-In timed out (no response within 40s)',
          );
        },
      );
      dev.log('[AuthService] Google account selected: ${account.email}');

  final googleAuth = await account.authentication;
  final idToken = googleAuth.idToken; 
      if (idToken == null) {
        dev.log('[AuthService] idToken null after authenticate(); attempting lightweight fallback');
        final Future<GoogleSignInAccount?>? maybe = GoogleSignIn.instance.attemptLightweightAuthentication();
        final GoogleSignInAccount? silent = maybe == null ? null : await maybe;
        final fallbackAuth = await silent?.authentication;
        final fallbackToken = fallbackAuth?.idToken;
        if (fallbackToken == null) {
          dev.log('[AuthService] Fallback also missing idToken -> likely configuration issue (SHA/clientId/google-services.json)');
          throw const GoogleSignInException(
            code: GoogleSignInExceptionCode.unknownError,
            description: 'Google ID token missing after authenticate() + fallback',
          );
        }
  final credential = GoogleAuthProvider.credential(idToken: fallbackToken);
        final credResult = await _auth.signInWithCredential(credential);
        dev.log('[AuthService] Firebase sign-in success via fallback user=${credResult.user?.uid}');
        try {
          await UserService.syncSignedInUser();
        } catch (e) {
          dev.log('[AuthService] Failed to sync user after fallback sign-in: $e');
        }
        return credResult;
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final credResult = await _auth.signInWithCredential(credential);
      dev.log('[AuthService] Firebase sign-in success user=${credResult.user?.uid} email=${credResult.user?.email}');
      try {
        await UserService.syncSignedInUser();
      } catch (e) {
        dev.log('[AuthService] Failed to sync user after sign-in: $e');
      }
      return credResult;
      
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        dev.log('[AuthService] Sign-in reported canceled. If this occurred immediately after selecting an account, re-verify configuration.');
        return null; 
      }
      dev.log('[AuthService] GoogleSignInException: code=${e.code} desc=${e.description}');
      rethrow;
    } catch (e) {
      dev.log('[AuthService] Unexpected error during Google sign-in: $e');
      rethrow;
    } finally {
      _interactiveInProgress = false;
    }
  }

  /// Attempt a lightweight (silent) authentication to restore a session.
  Future<bool> trySilentSignIn() async {
    await ensureInitialized();
    final Future<GoogleSignInAccount?>? attempt =
        GoogleSignIn.instance.attemptLightweightAuthentication();
    if (attempt == null) {
      return false;
    }
    final account = await attempt;
    if (account == null) return false;
    final idToken = account.authentication.idToken;
    if (idToken == null) return false;
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    await _auth.signInWithCredential(credential);
    return true;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (e) {
      dev.log('Error signing out: $e');
      rethrow;
    }
  }

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Get user photo URL
  String? get userPhotoUrl => _auth.currentUser?.photoURL;
}
