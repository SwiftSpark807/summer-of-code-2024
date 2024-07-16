import 'package:flutter/material.dart';
import 'package:flutter_application_1/components/my_list_tile.dart';

class MyDrawer extends StatelessWidget {
  final void Function()? goToProfile;
  final void Function()? signOut;
  const MyDrawer({
    super.key,
    required this.goToProfile,
    required this.signOut,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Drawer(
        backgroundColor: const Color.fromARGB(255, 7, 22, 45),
        child: Column(
          children: [
            //drawer
            DrawerHeader(
                child: Icon(
              Icons.person,
              color: const Color.fromARGB(255, 255, 255, 255),
              size: 64,
            )),

            //homepage

            MyListTile(
                icon: Icons.home,
                text: 'Home Page',
                func: () => Navigator.pop(context)),
            SizedBox(height: 10),
            //profile
            MyListTile(
                icon: Icons.account_circle, text: 'Profile', func: goToProfile),
            SizedBox(height: 10),
            MyListTile(icon: Icons.logout, text: 'Logout', func: signOut),

            //logout
          ],
        ),
      ),
    );
  }
}
