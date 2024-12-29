import 'package:flutter/material.dart';

class FailMessageWidget extends StatelessWidget {
  const FailMessageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
            "Something went wrong. Possibly to many api calls; please wait 1 minute before trying again."));
  }
}
