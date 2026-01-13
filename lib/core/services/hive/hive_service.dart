import 'package:artsphere/core/constants/hive_table_constant.dart';
import 'package:artsphere/features/auth/data/models/user_hive_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

// Hivfe Srevice Provider
final hiveServiceProvider = Provider<HiveService>((ref){
  return HiveService();
});

class HiveService {
  Future <void>init() async{
    final directory= await getApplicationDocumentsDirectory();

    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }
  
  // RegisterAdapter
  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userTypeId)) {
      Hive.registerAdapter(UserHiveModelAdapter());
    }
  }
  

  // Open Boxes
  Future<void> openBoxes() async {
    await Hive.openBox<UserHiveModel>(HiveTableConstant.userTable);
  }

  // Close Boxes
  Future<void> close() async{
    await Hive.close();
  }

// ================================================= User Queries =====================================================================//

// Makina a box for user things.
Box<UserHiveModel> get _userBox => Hive. box(HiveTableConstant.userTable);

// register user
Future <UserHiveModel> registerUser(UserHiveModel model)async{
  await _userBox.put(model.userId, model);
  return model;
}

// User Login
Future<UserHiveModel?> loginUser(String email, String password) async{

  final users= _userBox.values.where(
    (user)=>user.email == email && user.password==password,
  );
  if (users.isNotEmpty) {
    return users.first;
  }
  return null;
}

// user logout
Future<void>logout() async{

}

// Get Current User.
UserHiveModel? getCurrentUser(String userId){
  return _userBox.get(userId);
}

bool isEmailExists(String email) {
  final users= _userBox.values.where((user)=>user.email == email);
  return users.isNotEmpty;
}
}