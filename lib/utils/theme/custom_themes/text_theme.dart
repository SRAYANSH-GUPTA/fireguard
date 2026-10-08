import 'package:flutter/material.dart';
import '../../constants/typography.dart';
class TTextTheme {
  TTextTheme._();

  static TextTheme lightTheme = TextTheme(
     displayLarge: AppTypography.heading2,    
        displayMedium: AppTypography.heading1,   
        bodyLarge: AppTypography.body2,         
        bodyMedium: AppTypography.body1,        
        labelMedium: AppTypography.caption2,    
        labelSmall: AppTypography.caption1, 
        titleLarge: AppTypography.Yearfilters,   
  );
  static TextTheme darkTheme = TextTheme();
}