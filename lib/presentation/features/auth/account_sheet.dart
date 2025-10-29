import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:not_so_tic_tac_toe_game/auth/auth_manager.dart';
import 'package:not_so_tic_tac_toe_game/core/di/providers.dart';

class AccountSheet extends ConsumerWidget {
  const AccountSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(firebaseAuthProvider);
    final user = auth.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Text(
                'Account',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (user != null && !user.isAnonymous) ...[
                _SignedInDetails(user: user),
                const SizedBox(height: 16),
                const _ProfileEditSection(),
                const SizedBox(height: 16),
                const _LinkedProvidersSection(),
                const SizedBox(height: 16),
                const _EmailPasswordSection(),
                const SizedBox(height: 16),
                const _DangerZoneSection(),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () async {
                    try {
                      await ref.read(authManagerProvider).signOut();
                      if (context.mounted) Navigator.of(context).maybePop();
                    } catch (e) {
                      _showError(context, e);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign out'),
                ),
              ] else ...[
                Text(
                  'Sign in to save progress, sync across devices, and keep purchases.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                _SignInButtons(),
                const SizedBox(height: 16),
                const _EmailPasswordSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

class _SignedInDetails extends StatelessWidget {
  const _SignedInDetails({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
          child: user.photoURL == null
              ? const Icon(Icons.person_rounded, size: 28)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.displayName ?? 'Signed in',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (user.email != null)
                Text(
                  user.email!,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SignInButtons extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authManager = ref.watch(authManagerProvider);
    final accountService = ref.watch(playerAccountServiceProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: () async {
            try {
              await authManager.signInWithGoogle();
              await accountService.upsertCurrentUserProfile();
              if (context.mounted) Navigator.of(context).maybePop();
            } catch (e) {
              _showError(context, e);
            }
          },
          icon: const Icon(Icons.account_circle_rounded),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 10),
        FilledButton.tonalIcon(
          onPressed: () async {
            try {
              await authManager.signInWithApple();
              await accountService.upsertCurrentUserProfile();
              if (context.mounted) Navigator.of(context).maybePop();
            } catch (e) {
              _showError(context, e);
            }
          },
          icon: const Icon(Icons.apple_rounded),
          label: const Text('Continue with Apple'),
        ),
      ],
    );
  }

  void _showError(BuildContext context, Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }
}

class _ProfileEditSection extends ConsumerStatefulWidget {
  const _ProfileEditSection();

  @override
  ConsumerState<_ProfileEditSection> createState() => _ProfileEditSectionState();
}

class _ProfileEditSectionState extends ConsumerState<_ProfileEditSection> {
  final _nameCtrl = TextEditingController();
  final _photoCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(firebaseAuthProvider).currentUser;
    _nameCtrl.text = user?.displayName ?? '';
    _photoCtrl.text = user?.photoURL ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _photoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Profile', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: 'Display name',
            prefixIcon: Icon(Icons.badge_rounded),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _photoCtrl,
          decoration: InputDecoration(
            labelText: 'Avatar URL',
            prefixIcon: const Icon(Icons.image_rounded),
            suffixIcon: IconButton(
              onPressed: () {
                _photoCtrl.clear();
                setState(() {});
              },
              icon: const Icon(Icons.clear_rounded),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    try {
                      final account = ref.read(playerAccountServiceProvider);
                      if (_nameCtrl.text.trim().isNotEmpty) {
                        await account.updateDisplayName(_nameCtrl.text.trim());
                      }
                      await account.updatePhotoUrl(
                          _photoCtrl.text.trim().isEmpty ? null : _photoCtrl.text.trim());
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Profile updated')),
                        );
                      }
                    } catch (e) {
                      _snackError(context, e);
                    } finally {
                      if (mounted) setState(() => _saving = false);
                    }
                  },
            icon: const Icon(Icons.save_rounded),
            label: Text(_saving ? 'Saving...' : 'Save changes'),
          ),
        ),
      ],
    );
  }
}

class _LinkedProvidersSection extends ConsumerWidget {
  const _LinkedProvidersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authManagerProvider);
    final accountService = ref.watch(playerAccountServiceProvider);
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final providers = auth.linkedProviderIds();
    final isLastProvider = providers.where((p) => p != 'anonymous').length <= 1;

    Widget row({required IconData icon, required String label, required bool linked, required VoidCallback? onLink, required VoidCallback? onUnlink}) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Text(linked ? 'Linked' : 'Not linked'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!linked)
              OutlinedButton.icon(
                onPressed: onLink,
                icon: const Icon(Icons.link_rounded),
                label: const Text('Link'),
              ),
            if (linked)
              TextButton.icon(
                onPressed: isLastProvider ? null : onUnlink,
                icon: const Icon(Icons.link_off_rounded),
                label: const Text('Unlink'),
              ),
          ],
        ),
      );
    }

    Future<void> doLinkGoogle() async {
      try {
        await auth.linkWithGoogle();
        await accountService.upsertCurrentUserProfile();
      } catch (e) {
        _snackError(context, e);
      }
    }

    Future<void> doUnlink(String providerId) async {
      try {
        await auth.unlinkProvider(providerId);
        await accountService.upsertCurrentUserProfile();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          await _handleReauthPrompt(context, ref, providers);
          try {
            await auth.unlinkProvider(providerId);
            await accountService.upsertCurrentUserProfile();
          } catch (e) {
            _snackError(context, e);
          }
        } else {
          _snackError(context, e);
        }
      }
    }

    Future<void> doLinkApple() async {
      try {
        await auth.linkWithApple();
        await accountService.upsertCurrentUserProfile();
      } catch (e) {
        _snackError(context, e);
      }
    }

    Future<void> doLinkEmail() async {
      final result = await _showEmailPasswordDialog(context, title: 'Link email & password');
      if (result == null) return;
      try {
        await auth.linkWithEmailPassword(result.$1, result.$2);
        await accountService.upsertCurrentUserProfile();
      } on FirebaseAuthException catch (e) {
        _snackError(context, e.message ?? e.code);
      }
    }

    final googleLinked = providers.contains('google.com');
    final appleLinked = providers.contains('apple.com');
    final emailLinked = providers.contains('password');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Linked sign-in providers', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        row(
          icon: Icons.account_circle_rounded,
          label: 'Google',
          linked: googleLinked,
          onLink: doLinkGoogle,
          onUnlink: () => doUnlink('google.com'),
        ),
        row(
          icon: Icons.apple_rounded,
          label: 'Apple',
          linked: appleLinked,
          onLink: doLinkApple,
          onUnlink: () => doUnlink('apple.com'),
        ),
        row(
          icon: Icons.email_rounded,
          label: user?.email ?? 'Email & password',
          linked: emailLinked,
          onLink: doLinkEmail,
          onUnlink: () => doUnlink('password'),
        ),
        if (isLastProvider)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'You must keep at least one sign-in method linked.',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
      ],
    );
  }
}

class _EmailPasswordSection extends ConsumerStatefulWidget {
  const _EmailPasswordSection();

  @override
  ConsumerState<_EmailPasswordSection> createState() => _EmailPasswordSectionState();
}

class _EmailPasswordSectionState extends ConsumerState<_EmailPasswordSection> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(firebaseAuthProvider).currentUser;
    _emailCtrl.text = user?.email ?? '';
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final providers = ref.watch(authManagerProvider).linkedProviderIds();
    final emailLinked = providers.contains('password');
    final isAnonymous = user == null || user.isAnonymous;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email & password', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.alternate_email_rounded),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            prefixIcon: Icon(Icons.password_rounded),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            FilledButton(
              onPressed: _busy
                  ? null
                  : () async {
                      setState(() => _busy = true);
                      try {
                        final auth = ref.read(authManagerProvider);
                        if (isAnonymous || !emailLinked) {
                          await auth.signUpWithEmailPassword(
                            _emailCtrl.text.trim(),
                            _passwordCtrl.text,
                            linkIfAnonymous: true,
                          );
                        } else {
                          await auth.signInWithEmailPassword(
                            _emailCtrl.text.trim(),
                            _passwordCtrl.text,
                          );
                        }
                        await ref.read(playerAccountServiceProvider).upsertCurrentUserProfile();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isAnonymous || !emailLinked
                                  ? 'Email linked'
                                  : 'Signed in with email'),
                            ),
                          );
                        }
                      } on FirebaseAuthException catch (e) {
                        _snackError(context, e.message ?? e.code);
                      } finally {
                        if (mounted) setState(() => _busy = false);
                      }
                    },
              child: Text(isAnonymous || !emailLinked ? 'Link email' : 'Sign in'),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: _busy
                  ? null
                  : () async {
                      try {
                        await ref
                            .read(authManagerProvider)
                            .sendPasswordResetEmail(_emailCtrl.text.trim());
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password reset email sent')),
                          );
                        }
                      } catch (e) {
                        _snackError(context, e);
                      }
                    },
              child: const Text('Reset password'),
            ),
          ],
        ),
      ],
    );
  }
}

class _DangerZoneSection extends ConsumerWidget {
  const _DangerZoneSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Danger zone', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_forever_rounded, color: Colors.red),
          label: const Text('Delete account'),
          onPressed: () async {
            final confirm = await _confirmDeleteDialog(context);
            if (confirm != true) return;
            try {
              await ref.read(authManagerProvider).deleteAccount();
              await ref.read(playerAccountServiceProvider).softDeleteProfile();
              if (context.mounted) {
                Navigator.of(context).maybePop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deleted')),
                );
              }
            } on FirebaseAuthException catch (e) {
              if (e.code == 'requires-recent-login') {
                final providers = ref.read(authManagerProvider).linkedProviderIds();
                await _handleReauthPrompt(context, ref, providers);
                try {
                  await ref.read(authManagerProvider).deleteAccount();
                  await ref.read(playerAccountServiceProvider).softDeleteProfile();
                  if (context.mounted) {
                    Navigator.of(context).maybePop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Account deleted')),
                    );
                  }
                } catch (e) {
                  _snackError(context, e);
                }
              } else {
                _snackError(context, e);
              }
            } catch (e) {
              _snackError(context, e);
            }
          },
        ),
      ],
    );
  }
}

Future<bool?> _confirmDeleteDialog(BuildContext context) {
  final ctrl = TextEditingController();
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('This will permanently delete your account. Type DELETE to confirm.'),
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              decoration: const InputDecoration(hintText: 'DELETE'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text.trim().toUpperCase() == 'DELETE'),
            child: const Text('Confirm'),
          ),
        ],
      );
    },
  );
}

void _snackError(BuildContext context, Object e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString())),
  );
}

Future<void> _handleReauthPrompt(BuildContext context, WidgetRef ref, List<String> providers) async {
  // Choose a reauth method among linked providers; prefer email if present
  if (providers.contains('password')) {
    final result = await _showEmailPasswordDialog(context, title: 'Re-authenticate');
    if (result == null) return;
    await ref.read(authManagerProvider).reauthenticateWithEmail(result.$1, result.$2);
    return;
  }
  // Otherwise use the first available provider
  final providerId = providers.firstWhere(
    (p) => p == 'google.com' || p == 'apple.com',
    orElse: () => providers.first,
  );
  await ref.read(authManagerProvider).reauthenticateWithProvider(providerId);
}

Future<(String, String)?> _showEmailPasswordDialog(BuildContext context, {required String title}) {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  return showDialog<(String, String)>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.password_rounded),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop((emailCtrl.text.trim(), passCtrl.text)),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );
}
