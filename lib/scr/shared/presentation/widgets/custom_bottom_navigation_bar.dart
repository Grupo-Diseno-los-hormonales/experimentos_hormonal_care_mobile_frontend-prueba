import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context)?.homeTab ?? 'Home',
        ),
        BottomNavigationBarItem(
           icon: Icon(Icons.list),
          label: AppLocalizations.of(context)?.searchTab ?? 'Search',
        ),
        BottomNavigationBarItem(
         icon: Icon(Icons.calendar_today),
          label: AppLocalizations.of(context)?.appointmentsTab ?? 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: AppLocalizations.of(context)?.profileTab ?? 'Profile',
        ),
      ],
      selectedItemColor: const Color(0xFFA788AB),
      unselectedItemColor: const Color(0xFF8F7193),
      onTap: onTap,
    );
  }
}
