import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/profile/profile_bloc.dart';
import '../blocs/profile/profile_event.dart';
import '../blocs/profile/profile_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfile());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } else if (state is ProfileLoggedOut) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Logged out successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        } else if (state is ProfileDeleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black87,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        backgroundColor: Colors.black,
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.red),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(const LoadProfile());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded || state is ProfileUpdating) {
              final profile = state is ProfileLoaded
                  ? state.profile
                  : (state as ProfileUpdating).profile;

              return _buildProfileContent(profile, state is ProfileUpdating);
            }

            if (state is ProfileLoggedOut) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.orange, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'You have been logged out',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileDeleted) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.delete_forever, color: Colors.red, size: 64),
                    SizedBox(height: 16),
                    Text(
                      'Account has been deleted',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(UserProfile profile, bool isUpdating) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(profile),
          const SizedBox(height: 32),

          // Statistics
          _buildStatistics(profile),
          const SizedBox(height: 32),

          // Account Settings
          _buildAccountSettings(profile, isUpdating),
          const SizedBox(height: 32),

          // App Settings
          _buildAppSettings(profile),
          const SizedBox(height: 32),

          // Subscription
          _buildSubscriptionSection(profile, isUpdating),
          const SizedBox(height: 32),

          // Danger Zone
          _buildDangerZone(isUpdating),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage: NetworkImage(profile.avatarUrl),
            backgroundColor: Colors.grey[800],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile.email,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSubscriptionColor(profile.subscriptionPlan),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getPlanDisplayName(profile.subscriptionPlan),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Movies Watched',
                  profile.watchedMovies.toString(),
                  Icons.movie,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Hours Watched',
                  profile.watchedHours.toString(),
                  Icons.access_time,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Watchlist',
                  profile.watchlist.length.toString(),
                  Icons.bookmark,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Member Since',
                  '${profile.joinDate.year}',
                  Icons.calendar_today,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.red, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings(UserProfile profile, bool isUpdating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Account Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            'Username',
            profile.username,
            Icons.person,
            (value) {
              context.read<ProfileBloc>().add(UpdateUsername(value));
            },
            isUpdating,
          ),
          const SizedBox(height: 16),
          _buildEditableField(
            'Email',
            profile.email,
            Icons.email,
            (value) {
              context.read<ProfileBloc>().add(UpdateEmail(value));
            },
            isUpdating,
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    String value,
    IconData icon,
    Function(String) onUpdate,
    bool isUpdating,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(8),
          ),
          child: ListTile(
            leading: Icon(icon, color: Colors.white70),
            title: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.edit, color: Colors.red),
              onPressed: isUpdating
                  ? null
                  : () => _showEditDialog(label, value, onUpdate),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettings(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'Notifications',
            'Receive push notifications',
            Icons.notifications,
            profile.notificationsEnabled,
            (value) {
              context.read<ProfileBloc>().add(ToggleNotifications(value));
            },
          ),
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme',
            Icons.dark_mode,
            profile.darkModeEnabled,
            (value) {
              context.read<ProfileBloc>().add(ToggleDarkMode(value));
            },
          ),
          _buildDropdownTile(
            'Language',
            'App language',
            Icons.language,
            profile.language,
            ['English', 'Spanish', 'French', 'German', 'Japanese'],
            (value) {
              context.read<ProfileBloc>().add(ChangeLanguage(value));
            },
          ),
          _buildDropdownTile(
            'Video Quality',
            'Default video quality',
            Icons.hd,
            _getQualityDisplayName(profile.videoQuality),
            ['Auto', 'High', 'Medium', 'Low'],
            (value) {
              final quality = _getVideoQualityFromString(value);
              context.read<ProfileBloc>().add(ChangeVideoQuality(quality));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        secondary: Icon(icon, color: Colors.white70),
        value: value,
        onChanged: onChanged,
        activeColor: Colors.red,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> options,
    Function(String) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: DropdownButton<String>(
          value: value,
          dropdownColor: Colors.grey[800],
          style: const TextStyle(color: Colors.white),
          underline: Container(),
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSubscriptionSection(UserProfile profile, bool isUpdating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...SubscriptionPlan.values.map((plan) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: profile.subscriptionPlan == plan
                    ? Colors.red.withOpacity(0.2)
                    : Colors.black54,
                borderRadius: BorderRadius.circular(8),
                border: profile.subscriptionPlan == plan
                    ? Border.all(color: Colors.red)
                    : null,
              ),
              child: RadioListTile<SubscriptionPlan>(
                title: Text(
                  _getPlanDisplayName(plan),
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _getPlanDescription(plan),
                  style: const TextStyle(color: Colors.white70),
                ),
                value: plan,
                groupValue: profile.subscriptionPlan,
                onChanged: isUpdating
                    ? null
                    : (SubscriptionPlan? value) {
                        if (value != null) {
                          context
                              .read<ProfileBloc>()
                              .add(UpdateSubscriptionPlan(value));
                        }
                      },
                activeColor: Colors.red,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildDangerZone(bool isUpdating) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Danger Zone',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isUpdating
                  ? null
                  : () {
                      _showLogoutDialog();
                    },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.orange,
                side: const BorderSide(color: Colors.orange),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isUpdating
                  ? null
                  : () {
                      _showDeleteAccountDialog();
                    },
              icon: const Icon(Icons.delete_forever),
              label: const Text('Delete Account'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
      String field, String currentValue, Function(String) onUpdate) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          'Edit $field',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: field,
            labelStyle: const TextStyle(color: Colors.white70),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white70),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              onUpdate(controller.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(const LogoutUser());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Delete Account',
          style: TextStyle(color: Colors.red),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileBloc>().add(const DeleteAccount());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getSubscriptionColor(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return Colors.grey;
      case SubscriptionPlan.basic:
        return Colors.blue;
      case SubscriptionPlan.premium:
        return Colors.purple;
      case SubscriptionPlan.family:
        return Colors.green;
    }
  }

  String _getPlanDisplayName(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Free';
      case SubscriptionPlan.basic:
        return 'Basic';
      case SubscriptionPlan.premium:
        return 'Premium';
      case SubscriptionPlan.family:
        return 'Family';
    }
  }

  String _getPlanDescription(SubscriptionPlan plan) {
    switch (plan) {
      case SubscriptionPlan.free:
        return 'Limited content, ads';
      case SubscriptionPlan.basic:
        return '\$9.99/month, HD quality';
      case SubscriptionPlan.premium:
        return '\$15.99/month, 4K quality';
      case SubscriptionPlan.family:
        return '\$19.99/month, 6 accounts';
    }
  }

  String _getQualityDisplayName(VideoQuality quality) {
    switch (quality) {
      case VideoQuality.low:
        return 'Low';
      case VideoQuality.medium:
        return 'Medium';
      case VideoQuality.high:
        return 'High';
      case VideoQuality.auto:
        return 'Auto';
    }
  }

  VideoQuality _getVideoQualityFromString(String quality) {
    switch (quality) {
      case 'Low':
        return VideoQuality.low;
      case 'Medium':
        return VideoQuality.medium;
      case 'High':
        return VideoQuality.high;
      case 'Auto':
      default:
        return VideoQuality.auto;
    }
  }
}
