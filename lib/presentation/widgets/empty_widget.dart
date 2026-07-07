import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';

class EmptyWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyWidget({super.key, required this.message, this.icon = Icons.inbox});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.adaptiveText(context), width: 4),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon, size: 40, color: AppTheme.adaptiveTextSecondary(context)),
          ),
          const SizedBox(height: 16),
          Text(
            'KOSONG',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppTheme.adaptiveText(context),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.spaceGrotesk(
              color: AppTheme.adaptiveTextSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}