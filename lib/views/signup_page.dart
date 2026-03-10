import 'package:dolist/utils/toast.dart';
import 'package:dolist/views/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool agreeTerms = false;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter name";
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter email";
    }
    if (!value.contains("@")) {
      return "Enter valid email";
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Enter password";
    }
    if (value.length < 6) {
      return "Password must be 6 characters";
    }
    return null;
  }

  Future<void> signUp() async {

    if (!_formKey.currentState!.validate()) return;

    if (!agreeTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the terms")),
      );
      return;
    }
    if(passwordController.text != confirmPasswordController.text){
      ToastHelper.show("Passwords do not match");
      return;
    }
    try {

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      ToastHelper.show("Successfully Registered");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context)=>LoginPage()),
      );

    } on FirebaseAuthException catch(e){

      if(e.code == 'email-already-in-use'){
        ToastHelper.show("Email already registered");
      }
      else if(e.code == 'weak-password'){
        ToastHelper.show("Password too weak");
      }
      else{
        ToastHelper.show(e.message ?? "Signup failed");
      }

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.deepPurpleAccent,

      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              height:
              MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0,5),
                  )
                ],
              ),

              child: Column(
                children: [
                  Image.asset(
                    "assets/add.png",
                    height: 100,
                    width: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(labelText: "Name"),
                          validator: validateName,
                        ),
                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                           validator: validateEmail,
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: passwordController,
                          validator: validatePassword,
                          obscureText: obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        TextFormField(
                          controller: confirmPasswordController,
                          validator: validatePassword,
                          obscureText: obscureConfirm,
                          decoration: InputDecoration(
                            labelText: "Confirm Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscureConfirm = !obscureConfirm;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Checkbox(
                        value: agreeTerms,
                        onChanged: (value) {
                          setState(() {
                            agreeTerms = value!;
                          });
                        },
                      ),
                      const Expanded(
                        child: Text(
                          "By signing up you agree to the Terms & Conditions and Privacy Policy",
                          style: TextStyle(fontSize: 12),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 15),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                        ),
                        onPressed: signUp,
                        child: const Text("Sign Up",style: TextStyle(color: Colors.white),),
                      ),

                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.deepPurple),
                        ),
                        onPressed: (){
                          Navigator.pushReplacement
                            (context, MaterialPageRoute(builder: (context)=>LoginPage()));
                        },
                        child: const Text("Cancel",style: TextStyle(color: Colors.white),),
                      )

                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      const Text("Already have account?"),

                      const SizedBox(width: 5),

                      GestureDetector(
                        onTap: (){
                          Navigator.pushReplacement
                            (context, MaterialPageRoute(builder: (context)=>LoginPage()));
                        },
                        child: const Text(
                          "Sign in ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      )

                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
