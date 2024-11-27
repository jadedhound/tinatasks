import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:tinatasks/api/client.dart';
import 'package:tinatasks/global.dart';
import 'package:tinatasks/models/user.dart';
import 'package:tinatasks/pages/user/register.dart';
import 'package:tinatasks/theme/button.dart';
import 'package:tinatasks/theme/buttonText.dart';
import 'package:tinatasks/theme/constants.dart';
import 'package:tinatasks/utils/validator.dart';

import '../../components/SentryModal.dart';
import '../../models/server.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _rememberMe = false;
  bool init = false;
  List<String> pastServers = [];

  final _serverController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final _serverSuggestionController = SuggestionsController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if (VikunjaGlobal.of(context).expired) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login has expired. Please reenter your details!")));
        setState(() {
          _serverController.text = VikunjaGlobal.of(context).client.base;
          _usernameController.text =
              VikunjaGlobal.of(context).currentUser?.username ?? "";
        });
      }
      final client = VikunjaGlobal.of(context).client;
      await VikunjaGlobal.of(context)
          .settingsManager
          .getIgnoreCertificates()
          .then((value) =>
              setState(() => client.ignoreCertificates = value == "1"));

      await VikunjaGlobal.of(context)
          .settingsManager
          .getPastServers()
          .then((value) {
        print(value);
        if (value != null) setState(() => pastServers = value);
      });
      showSentryModal(context, VikunjaGlobal.of(context));
    });
  }

  @override
  Widget build(BuildContext ctx) {
    Client client = VikunjaGlobal.of(context).client;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Builder(
            builder: (BuildContext context) => Form(
              autovalidateMode: AutovalidateMode.always,
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/graphics/llama.svg',
                        height: 96,
                        semanticsLabel: 'Vikunja Logo',
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                        child: Text(
                          style: TextStyle(
                            fontSize: 40,
                            fontFamily: 'Quicksand',
                          ),
                          'TinaTasks',
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: vStandardVerticalPadding,
                    child: Row(children: [
                      Expanded(
                        child: TypeAheadField(
                          //suggestionsBoxController: _serverSuggestionController,
                          //getImmediateSuggestions: true,
                          //enabled: !_loading,
                          controller: _serverController,
                          builder: (context, controller, focusnode) {
                            return TextFormField(
                              controller: controller,
                              focusNode: focusnode,
                              enabled: !_loading,
                              validator: (address) {
                                return (isUrl(address) ||
                                        address != null ||
                                        address!.isEmpty)
                                    ? null
                                    : 'Invalid URL';
                              },
                              decoration: new InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Server Address'),
                            );
                          },
                          /*
                          textFieldConfiguration: TextFieldConfiguration(
                            controller: _serverController,
                            decoration: new InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Server Address'),
                          ),*/
                          onSelected: (suggestion) {
                            _serverController.text = suggestion;
                            setState(() => _serverController.text = suggestion);
                          },
                          itemBuilder:
                              (BuildContext context, Object? itemData) {
                            return Card(
                                child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(itemData.toString()),
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                pastServers.remove(
                                                    itemData.toString());
                                                //_serverSuggestionController.suggestionsBox?.close();
                                                VikunjaGlobal.of(context)
                                                    .settingsManager
                                                    .setPastServers(
                                                        pastServers);
                                              });
                                            },
                                            icon: Icon(Icons.clear))
                                      ],
                                    )));
                          },
                          suggestionsCallback: (String pattern) {
                            List<String> matches = <String>[];
                            matches.addAll(pastServers);
                            matches.retainWhere((s) {
                              return s
                                  .toLowerCase()
                                  .contains(pattern.toLowerCase());
                            });
                            return matches;
                          },
                        ),
                      ),
                      /*
                      DropdownButton<String>(
                        onChanged: (String? value) {
                          // This is called when the user selects an item.
                          setState(() {
                            if (value != null) _serverController.text = value;
                          });
                        },
                        items: pastServers
                            .map<DropdownMenuItem<String>>((dynamic value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),*/
                    ]),
                  ),
                  Padding(
                    padding: vStandardVerticalPadding,
                    child: TextFormField(
                      enabled: !_loading,
                      controller: _usernameController,
                      autofillHints: [AutofillHints.username],
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Username'),
                    ),
                  ),
                  Padding(
                    padding: vStandardVerticalPadding,
                    child: TextFormField(
                      enabled: !_loading,
                      controller: _passwordController,
                      autofillHints: [AutofillHints.password],
                      decoration: new InputDecoration(
                          border: OutlineInputBorder(), labelText: 'Password'),
                      obscureText: true,
                    ),
                  ),
                  Padding(
                    padding: vStandardVerticalPadding,
                    child: CheckboxListTile(
                      value: _rememberMe,
                      onChanged: (value) =>
                          setState(() => _rememberMe = value ?? false),
                      title: Text("Remember me"),
                    ),
                  ),
                  Builder(
                      builder: (context) => FancyButton(
                            onPressed: !_loading
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      Form.of(context).save();
                                      _loginUser(context);
                                    }
                                  }
                                : null,
                            child: _loading
                                ? CircularProgressIndicator()
                                : VikunjaButtonText('Login'),
                          )),
                  Builder(
                      builder: (context) => FancyButton(
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterPage())),
                            child: VikunjaButtonText('Register'),
                          )),
                  CheckboxListTile(
                      title: Text("Ignore Certificates"),
                      value: client.ignoreCertificates,
                      onChanged: (value) {
                        setState(
                            () => client.reloadIgnoreCerts(value ?? false));
                        VikunjaGlobal.of(context)
                            .settingsManager
                            .setIgnoreCertificates(value ?? false);
                        VikunjaGlobal.of(context).client.ignoreCertificates =
                            value ?? false;
                      }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _loginUser(BuildContext context) async {
    String _server = _serverController.text;
    String _username = _usernameController.text;
    String _password = _passwordController.text;
    if (_server.isEmpty) return;

    if (!pastServers.contains(_server)) pastServers.add(_server);
    await VikunjaGlobal.of(context).settingsManager.setPastServers(pastServers);

    setState(() => _loading = true);
    try {
      var vGlobal = VikunjaGlobal.of(context);
      vGlobal.client.showSnackBar = false;
      vGlobal.client.configure(base: _server);
      Server? info = await vGlobal.serverService.getInfo();

      UserTokenPair newUser;

      newUser = await vGlobal.newUserService!
          .login(_username, _password, rememberMe: this._rememberMe);

      if (newUser.error == 1017) {
        TextEditingController totpController = TextEditingController();
        bool dismissed = true;
        await showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: Text("Enter One Time Passcode"),
            content: TextField(
              controller: totpController,
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    dismissed = false;
                    Navigator.pop(context);
                  },
                  child: Text("Login"))
            ],
          ),
        );
        if (!dismissed) {
          newUser = await vGlobal.newUserService!.login(_username, _password,
              rememberMe: this._rememberMe, totp: totpController.text);
        } else {
          throw Exception();
        }
      }
      if (newUser.error > 0) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(newUser.errorString)));
      }

      if (newUser.error == 0)
        vGlobal.changeUser(newUser.user!, token: newUser.token, base: _server);
    } catch (ex) {
      print(ex);
      /*  log(stacktrace.toString());
      showDialog(
          context: context,
          builder: (context) => new AlertDialog(
                title: Text(
                    'Login failed! Please check your server url and credentials. ' +
                        ex.toString()),
                actions: <Widget>[
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'))
                ],
              ));
     */
    } finally {
      VikunjaGlobal.of(context).client.showSnackBar = true;
      setState(() {
        _loading = false;
      });
    }
  }
}
