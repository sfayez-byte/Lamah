/*import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  bool _isEditing = false;
  bool _hasProfileRow = false;

  String _fullName = "";
  String _phone = "";
  String _email = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found. Please log in.")),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _hasProfileRow = false;
          _fullName = "";
          _phone = "";
          _email = user.email ?? "";
        });
      } else {
        setState(() {
          _hasProfileRow = true;
          _fullName = response['full_name']?.toString() ?? "";
          _phone = response['phone']?.toString() ?? "";
          _email = response['email']?.toString() ?? user.email ?? "";
        });
      }

      _nameController.text = _fullName;
      _phoneController.text = _phone;
      _emailController.text = _email;

    } catch (error, stack) {
      debugPrint("Fetch Error: $error\nStack: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading profile: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    final user = _supabase.auth.currentUser;
    if (user == null || !mounted) {
      setState(() => _isLoading = false);
      return;
    }

    final updatedName = _nameController.text.trim();
    final updatedPhone = _phoneController.text.trim();
    final updatedEmail = _emailController.text.trim();

    debugPrint("Saving Profile:");
    debugPrint("Name: $updatedName");
    debugPrint("Phone: $updatedPhone");
    debugPrint("Email: $updatedEmail");

    try {
      if (_hasProfileRow) {
        debugPrint("Updating profile for user: ${user.id}");
        final updatedData = await _supabase
            .from('profiles')
            .update({
              'full_name': updatedName.isNotEmpty ? updatedName : null,
              'phone': updatedPhone.isNotEmpty ? updatedPhone : null,
              'email': updatedEmail.isNotEmpty ? updatedEmail : null,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', user.id)
            .select()
            .single();

        debugPrint("Update Response: $updatedData");

        setState(() {
          _fullName = updatedData['full_name']?.toString() ?? "";
          _phone = updatedData['phone']?.toString() ?? "";
          _email = updatedData['email']?.toString() ?? user.email ?? "";
        });

      } else {
        debugPrint("Creating profile for user: ${user.id}");
        final newData = await _supabase
            .from('profiles')
            .insert({
              'id': user.id,
              'full_name': updatedName.isNotEmpty ? updatedName : null,
              'phone': updatedPhone.isNotEmpty ? updatedPhone : null,
              'email': updatedEmail.isNotEmpty ? updatedEmail : null,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

        debugPrint("Insert Response: $newData");

        setState(() {
          _hasProfileRow = true;
          _fullName = newData['full_name']?.toString() ?? "";
          _phone = newData['phone']?.toString() ?? "";
          _email = newData['email']?.toString() ?? user.email ?? "";
        });
      }

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on PostgrestException catch (error, stack) {
      debugPrint("Supabase Error: ${error.message}\nDetails: ${error.details}\nStack: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save: ${error.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error, stack) {
      debugPrint("General Error: $error\nStack: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = _fullName;
        _phoneController.text = _phone;
        _emailController.text = _email;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: const Color(0xFF2E225A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing ? _buildEditForm() : _buildReadOnlyView(),
            ),
    );
  }

  Widget _buildReadOnlyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileItem("Full Name", _fullName),
        const SizedBox(height: 16),
        _profileItem("Email", _email),
        const SizedBox(height: 16),
        _profileItem("Phone", _phone),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E225A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text("Edit Profile"),
            
          ),
        ),
      ],
    );
  }



  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editField("Full Name", _nameController),
        const SizedBox(height: 16),
        _editField("Email", _emailController),
        const SizedBox(height: 16),
        _editField("Phone", _phoneController),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E225A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Save Changes"),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _toggleEditMode,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _profileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : "Not set",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
      ],
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2E225A)),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}*/
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  bool _isEditing = false;
  bool _hasProfileRow = false;

  String _fullName = "";
  String _phone = "";
  String _email = "";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  SupabaseClient get _supabase => Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    setState(() => _isLoading = true);

    final user = _supabase.auth.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No user found. Please log in.")),
        );
      }
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select('*')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _hasProfileRow = false;
          _fullName = "";
          _phone = "";
          _email = user.email ?? "";
        });
      } else {
        setState(() {
          _hasProfileRow = true;
          _fullName = response['full_name']?.toString() ?? "";
          _phone = response['phone']?.toString() ?? "";
          _email = response['email']?.toString() ?? user.email ?? "";
        });
      }

      _nameController.text = _fullName;
      _phoneController.text = _phone;
      _emailController.text = _email;

    } catch (error, stack) {
      debugPrint("Fetch Error: $error\nStack: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error loading profile: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);

    final user = _supabase.auth.currentUser;
    if (user == null || !mounted) {
      setState(() => _isLoading = false);
      return;
    }

    final updatedName = _nameController.text.trim();
    final updatedPhone = _phoneController.text.trim();
    final updatedEmail = _emailController.text.trim();

    debugPrint("Saving Profile:");
    debugPrint("Name: $updatedName");
    debugPrint("Phone: $updatedPhone");
    debugPrint("Email: $updatedEmail");

    try {
      if (_hasProfileRow) {
        debugPrint("Updating profile for user: ${user.id}");
        final updatedData = await _supabase
            .from('profiles')
            .update({
              'full_name': updatedName.isNotEmpty ? updatedName : null,
              'phone': updatedPhone.isNotEmpty ? updatedPhone : null,
              'email': updatedEmail.isNotEmpty ? updatedEmail : null,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .eq('id', user.id)
            .select()
            .single();

        debugPrint("Update Response: $updatedData");

        setState(() {
          _fullName = updatedData['full_name']?.toString() ?? "";
          _phone = updatedData['phone']?.toString() ?? "";
          _email = updatedData['email']?.toString() ?? user.email ?? "";
        });

      } else {
        debugPrint("Creating profile for user: ${user.id}");
        final newData = await _supabase
            .from('profiles')
            .insert({
              'id': user.id,
              'full_name': updatedName.isNotEmpty ? updatedName : null,
              'phone': updatedPhone.isNotEmpty ? updatedPhone : null,
              'email': updatedEmail.isNotEmpty ? updatedEmail : null,
              'updated_at': DateTime.now().toUtc().toIso8601String(),
            })
            .select()
            .single();

        debugPrint("Insert Response: $newData");

        setState(() {
          _hasProfileRow = true;
          _fullName = newData['full_name']?.toString() ?? "";
          _phone = newData['phone']?.toString() ?? "";
          _email = newData['email']?.toString() ?? user.email ?? "";
        });
      }

      setState(() => _isEditing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }

    } on PostgrestException catch (error, stack) {
      debugPrint("Supabase Error: ${error.message}\nDetails: ${error.details}\nStack: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save: ${error.message}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error, stack) {
      debugPrint("General Error: $error\nStack: $stack");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Unexpected error: ${error.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = _fullName;
        _phoneController.text = _phone;
        _emailController.text = _email;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(color: Colors.white), // Changed color to white
        ),
        backgroundColor: const Color(0xFF2E225A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
          color: Colors.white
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: _isEditing ? _buildEditForm() : _buildReadOnlyView(),
            ),
    );
  }

  Widget _buildReadOnlyView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profileItem("Full Name", _fullName),
        const SizedBox(height: 16),
        _profileItem("Email", _email),
        const SizedBox(height: 16),
        _profileItem("Phone", _phone),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2E225A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              "Edit Profile",
              style: TextStyle(color: Colors.white), // Changed color to white
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _editField("Full Name", _nameController),
        const SizedBox(height: 16),
        _editField("Email", _emailController),
        const SizedBox(height: 16),
        _editField("Phone", _phoneController),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E225A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text("Save Changes"),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: _toggleEditMode,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _profileItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.isNotEmpty ? value : "Not set",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Divider(height: 1),
      ],
    );
  }

  Widget _editField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2E225A)),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
