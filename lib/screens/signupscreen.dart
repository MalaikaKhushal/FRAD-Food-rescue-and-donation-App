import 'package:flutter/material.dart';
import 'package:frad/screens/loginscreen.dart';

import 'landingpage.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();

  final TextEditingController emailController = TextEditingController();

  final TextEditingController phoneController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool hidePassword = true;
  bool hideConfirmPassword = true;

  bool agreeTerms = false;

  String? selectedRole;

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

  void register() {
    if (_formKey.currentState!.validate()) {
      if (selectedRole == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Please select a role")));
        return;
      }

      if (!agreeTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please accept Terms & Conditions")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Firebase Registration Coming Soon")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,

      body: Container(
        width: double.infinity,

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xffF57C00), Color(0xffFF9800), Color(0xffFFB74D)],
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),

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

                  const SizedBox(height: 10),

                  Container(
                    height: 110,
                    width: 110,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),

                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.person_add_alt_1,
                      color: Color(0xffF57C00),
                      size: 65,
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
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
                        TextFormField(
                          controller: fullNameController,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
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

                        TextFormField(
                          controller: emailController,

                          keyboardType: TextInputType.emailAddress,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
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

                        TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Phone Number";
                            }

                            if (value.length < 11) {
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

                        TextFormField(
                          controller: passwordController,
                          obscureText: hidePassword,

                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Enter Password";
                            }

                            if (value.length < 6) {
                              return "Minimum 6 characters";
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

                          items: roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),

                          onChanged: (value) {
                            setState(() {
                              selectedRole = value;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Checkbox(
                              activeColor: const Color(0xffF57C00),
                              value: agreeTerms,

                              onChanged: (value) {
                                setState(() {
                                  agreeTerms = value!;
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
                            onPressed: register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffF57C00),
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "CREATE ACCOUNT",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Row(
                          children: const [
                            Expanded(child: Divider(thickness: 1)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text("OR"),
                            ),
                            Expanded(child: Divider(thickness: 1)),
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
                                    builder: (context) => const LoginScreen(),
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
