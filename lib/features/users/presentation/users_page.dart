// import 'package:edukita/features/common/feature_cubit.dart';
// import 'package:edukita/features/common/feature_page.dart';
// import 'package:edukita/features/common/feature_state.dart';
// import 'package:edukita/features/users/user_form_card.dart';
// import 'package:edukita/features/users/user_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// class UsersPage extends StatelessWidget {
//   const UsersPage({super.key});

//   Future<void> _showUserFormDialog(
//     BuildContext context, {
//     User? existingUser,
//   }) async {
//     final cubit = context.read<FeatureCubit<User>>();
//     final isEditing = existingUser != null;

//     await showDialog<void>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(isEditing ? 'Update User' : 'Add User'),
//           content: SingleChildScrollView(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 500),
//               child: UserFormCard(
//                 initialUser: existingUser,
//                 isEditing: isEditing,
//                 onSubmit: (user) async {
//                   if (isEditing) {
//                     await cubit.updateItem(existingUser.id, {
//                       'nick_name': user.nickName,
//                       'full_name': user.fullName,
//                     }, context);
//                   } else {
//                     await cubit.addItem(user, context);
//                   }

//                   if (context.mounted) {
//                     Navigator.of(context).pop();
//                   }
//                 },
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<FeatureCubit<User>, FeatureState<User>>(
//       builder: (context, state) {
//         return FeaturePage(
//           title: 'User Management',
//           subtitle: 'Manage foundation roles and permissions.',
//           itemsCount: state.items.length,
//           addButtonLabel: 'Add User',
//           onAddPressed: () => _showUserFormDialog(context),
//           errorMessage: state.message,
//           body: state.loading
//               ? const Center(child: CircularProgressIndicator())
//               : state.items.isEmpty
//               ? const Center(child: Text('No users yet. Add a user.'))
//               : ListView.builder(
//                   itemCount: state.items.length,
//                   itemBuilder: (context, index) {
//                     final user = state.items[index];
//                     return ListTile(
//                       leading: const Icon(Icons.person),
//                       title: Text(user.fullName),
//                       subtitle: Text('${user.username} • ${user.nickName}'),
//                       trailing: IconButton(
//                         icon: const Icon(Icons.edit),
//                         onPressed: () =>
//                             _showUserFormDialog(context, existingUser: user),
//                       ),
//                     );
//                   },
//                 ),
//         );
//       },
//     );
//   }
// }
