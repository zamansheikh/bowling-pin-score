import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../routing/app_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🎳 Settings'),
        backgroundColor: Colors.brown.shade700,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.brown.shade600, Colors.brown.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(Icons.settings, color: Colors.white, size: 48),
                  SizedBox(height: 12),
                  Text(
                    'BOWLING SETTINGS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Customize your bowling experience',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingL),

            // Game Settings
            Text(
              'Game Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.speed, color: Colors.brown.shade600),
                    title: const Text('Animation Speed'),
                    subtitle: const Text('Pin knock-down animation speed'),
                    trailing: DropdownButton<String>(
                      value: 'Normal',
                      items: const [
                        DropdownMenuItem(value: 'Slow', child: Text('Slow')),
                        DropdownMenuItem(
                          value: 'Normal',
                          child: Text('Normal'),
                        ),
                        DropdownMenuItem(value: 'Fast', child: Text('Fast')),
                      ],
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Animation speed: $value'),
                            backgroundColor: Colors.brown.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.vibration,
                      color: Colors.brown.shade600,
                    ),
                    title: const Text('Haptic Feedback'),
                    subtitle: const Text('Vibrate when pins are knocked down'),
                    trailing: Switch(
                      value: true,
                      activeColor: Colors.brown.shade600,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Haptic feedback: ${value ? 'On' : 'Off'}',
                            ),
                            backgroundColor: Colors.brown.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.volume_up,
                      color: Colors.brown.shade600,
                    ),
                    title: const Text('Sound Effects'),
                    subtitle: const Text('Play sounds for strikes and spares'),
                    trailing: Switch(
                      value: false,
                      activeColor: Colors.brown.shade600,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sound effects: ${value ? 'On' : 'Off'}',
                            ),
                            backgroundColor: Colors.brown.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingL),

            // App Settings
            Text(
              'App Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.palette, color: Colors.brown.shade600),
                    title: const Text('Theme'),
                    subtitle: const Text('Light/Dark mode'),
                    trailing: Switch(
                      value: Theme.of(context).brightness == Brightness.dark,
                      activeColor: Colors.brown.shade600,
                      onChanged: (value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Theme switching coming soon!'),
                            backgroundColor: Colors.brown.shade600,
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(Icons.info, color: Colors.brown.shade600),
                    title: const Text('About'),
                    subtitle: const Text('App version and info'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: AppConstants.appName,
                        applicationVersion: AppConstants.appVersion,
                        applicationIcon: Icon(
                          Icons.sports,
                          size: 48,
                          color: Colors.brown.shade600,
                        ),
                        children: [
                          const Text(
                            'A visual bowling pin score tracker built with Flutter. '
                            'Features interactive pin selection, real-time scoring, '
                            'and professional bowling lane design. Built with Clean Architecture '
                            'and modern development practices.',
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingL),

            // Navigation
            Text(
              'Navigation',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.brown.shade800,
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.home, color: Colors.blue.shade600),
                    title: const Text('Demo Mode'),
                    subtitle: const Text('Interactive pin selection demo'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(AppRoutes.home),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      Icons.sports_score,
                      color: Colors.green.shade600,
                    ),
                    title: const Text('Full Game'),
                    subtitle: const Text('Complete bowling game with scoring'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.go(AppRoutes.fullGame),
                  ),
                ],
              ),
            ),

            const SizedBox(height: UIConstants.spacingL),

            // Danger Zone
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red.shade300),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.delete_forever,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  'Reset Game Data',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
                subtitle: const Text('Clear all bowling game data'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Game Data'),
                      content: const Text(
                        'Are you sure you want to reset all bowling game data? '
                        'This will clear your game history and current progress. '
                        'This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade600,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Game data reset!'),
                                backgroundColor: Colors.red.shade600,
                                action: SnackBarAction(
                                  label: 'Undo',
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Data restored!'),
                                        backgroundColor: Colors.green.shade600,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            'Reset',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
