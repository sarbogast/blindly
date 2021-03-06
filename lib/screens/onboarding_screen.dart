import 'package:blindly/screens/phone_number_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class OnboardingScreen extends StatelessWidget {
  void _signIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PhoneNumberScreen(),
      ),
    );
  }

  void _resetPassword() {
    //TODO
  }

  Future<void> _openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/logo_full.png',
                  height: MediaQuery.of(context).size.height / 5,
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
              child: MarkdownBody(
                data:
                    'By clicking "Log in", you agree with our [Terms of Service](https://sebastien-arbogast.com). Learn how we process your data in [Privacy Policy](https://blindlyapp.com/privacy) and [Cookies Policy](https://blindlyapp.com/cookies).',
                styleSheet: MarkdownStyleSheet(
                  textAlign: WrapAlignment.center,
                  a: TextStyle(
                    color: Theme.of(context).textTheme.bodyText1.color,
                    decoration: TextDecoration.underline,
                  ),
                  p: TextStyle(
                    height: 1.75,
                  ),
                ),
                onTapLink: (_, href, __) => _openLink(href),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 9,
                  ),
                  child: ElevatedButton(
                    child: Text(
                      AppLocalizations.of(context).signIn.toUpperCase(),
                    ),
                    onPressed: () => _signIn(context),
                  ),
                ),
                /*Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 9,
                  ),
                  child: OutlinedButton(
                    child: Text(
                      AppLocalizations.of(context).signIn.toUpperCase(),
                    ),
                    onPressed: _signIn,
                  ),
                ),*/
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 9,
                  ),
                  child: TextButton(
                    child: Text(
                      AppLocalizations.of(context).troubleLoggingIn,
                      style: Theme.of(context).textTheme.bodyText2,
                    ),
                    onPressed: _resetPassword,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
