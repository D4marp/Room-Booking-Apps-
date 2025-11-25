import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign up with email and password
  static Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(name);

      // Create user document in Firestore
      if (credential.user != null) {
        await _createUserDocument(credential.user!, name);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with email and password
  static Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Sign in with Google (disabled - use email/password instead)
  static Future<UserCredential?> signInWithGoogle() async {
    throw 'Google Sign-In is currently disabled. Please use email/password login.';
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw 'Error signing out. Please try again.';
    }
  }

  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Delete account
  static Future<void> deleteAccount() async {
    try {
      final user = currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred while deleting account.';
    }
  }

  // Get user document from Firestore
  static Future<UserModel?> getUserDocument(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Error fetching user data.';
    }
  }

  // Update user document in Firestore
  static Future<void> updateUserDocument(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(
            user.copyWith(updatedAt: DateTime.now()).toJson(),
            SetOptions(merge: true),
          );
    } catch (e) {
      throw 'Error updating user data.';
    }
  }

  // Create user document in Firestore
  static Future<void> _createUserDocument(User user, String name) async {
    try {
      // Create user document with default 'user' role
      await _firestore.collection('users').doc(user.uid).set({
        'id': user.uid,
        'name': name,
        'email': user.email ?? '',
        'profileImage': user.photoURL,
        'role': 'user', // Default to regular user
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      // Don't throw here as user is already created
      print('Error creating user document: $e');
    }
  }

  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled.';
      case 'invalid-credential':
        return 'Invalid credentials provided.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }

  // Check if email is verified
  static bool get isEmailVerified => currentUser?.emailVerified ?? false;

  // Send email verification
  static Future<void> sendEmailVerification() async {
    try {
      await currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Reload user
  static Future<void> reloadUser() async {
    await currentUser?.reload();
  }
}
