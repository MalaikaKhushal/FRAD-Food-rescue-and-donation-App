import 'package:flutter/material.dart';
import '../services/auth-service.dart';
import 'loginscreen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final AuthService _authService = AuthService();

  bool isLoading = false;

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  bool agreeTerms = false;

  String selectedRole = "Customer";

  final List<String> roles = [
    "Customer",
    "Restaurant",
    "Bakery",
    "Hostel Mess",
    "Event Caterer",
  ];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please accept Terms & Conditions")),
      );
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() {
      isLoading = true;
    });

    String result = await _authService.signUpUser(
      fullName: fullNameController.text.trim(),
      email: emailController.text.trim(),
      phone: phoneController.text.trim(),
      password: passwordController.text.trim(),
      role: selectedRole,
    );

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }

    if (result == "success") {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Created Successfully"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xffF57C00), Color(0xffFF9800), Color(0xffFFB74D)],
            ),
          ),

          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),

            padding: EdgeInsets.symmetric(
              horizontal: size.width * .07,
              vertical: 20,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,

                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                      ),

                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  SizedBox(height: size.height * .01),

                  Container(
                    height: 110,
                    width: 110,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.person_add_alt_1,
                      size: 65,
                      color: Color(0xffF57C00),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Join FRAD & Rescue Food",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  Container(
                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),

                    child: Column(
                      children: [
                        // Full Name
                        TextFormField(
                          controller: fullNameController,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter Full Name";
                            }
                            return null;
                          },

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person,
                              color: Color(0xffF57C00),
                            ),

                            labelText: "Full Name",

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter Email";
                            }

                            if (!value.contains("@")) {
                              return "Invalid Email";
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Color(0xffF57C00),
                            ),

                            labelText: "Email Address",

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Phone Number
                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Enter Phone Number";
                            }

                            if (value.trim().length < 11) {
                              return "Invalid Phone Number";
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone,
                              color: Color(0xffF57C00),
                            ),
                            labelText: "Phone Number",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Password
                        TextFormField(
                          controller: passwordController,
                          obscureText: hidePassword,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Password";
                            }

                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xffF57C00),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),

                              onPressed: () {
                                setState(() {
                                  hidePassword = !hidePassword;
                                });
                              },
                            ),

                            labelText: "Password",

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Confirm Password
                        TextFormField(
                          controller: confirmPasswordController,
                          obscureText: hideConfirmPassword,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm Password";
                            }

                            if (value != passwordController.text) {
                              return "Passwords do not match";
                            }

                            return null;
                          },

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.lock_reset,
                              color: Color(0xffF57C00),
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                hideConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),

                              onPressed: () {
                                setState(() {
                                  hideConfirmPassword = !hideConfirmPassword;
                                });
                              },
                            ),

                            labelText: "Confirm Password",

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Role Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedRole,

                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.badge,
                              color: Color(0xffF57C00),
                            ),

                            labelText: "Select Role",

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),

                          items: roles
                              .map(
                                (role) => DropdownMenuItem(
                                  value: role,
                                  child: Text(role),
                                ),
                              )
                              .toList(),

                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: agreeTerms,
                              activeColor: const Color(0xffF57C00),

                              onChanged: (value) {
                                setState(() {
                                  agreeTerms = value ?? false;
                                });
                              },
                            ),

                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 12),
                                child: Text(
                                  "I agree to the Terms & Conditions and Privacy Policy.",
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 55,

                          child: ElevatedButton(
                            onPressed: isLoading ? null : signUp,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffF57C00),
                              foregroundColor: Colors.white,
                              elevation: 5,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),

                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Create Account",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("OR"),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,

                          children: [
                            const Text(
                              "Already have an account?",
                              style: TextStyle(fontSize: 15),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },

                              child: const Text(
                                "Sign In",
                                style: TextStyle(
                                  color: Color(0xffF57C00),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
