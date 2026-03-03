<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    //
    public function register (Request $request)
    {
       //
       $fields = $request->validate([
    'name' => [
    'required',
    'string',
    // Autorise : A-Z, a-z, espaces, et les accents français courants
    'regex:/^[a-zA-Z\sàâäéèêëîïôöùûüÿçÀÂÄÉÈÊËÎÏÔÖÙÛÜŸÇ]+$/u',
],
    'email'    => 'required|string|email|unique:users,email',
    'password' => 'required|string|min:6|confirmed',
]);

       $user = User::create([
        'name' => $fields['name'],
        'email' => $fields['email'],
        'password' => bcrypt($fields['password']),
       ]);

       $token = $user->createToken('myapptoken')->plainTextToken;

       return response()->json(['user' => $user, 'token' => $token], 201);
    }

   public function login(Request $request) {
    $request->validate([
        'email' => 'required|email',
        'password' => 'required',
    ]);

    $user = User::where('email', $request->email)->first();

    // Debug : tu peux ajouter return $user; ici pour voir s'il le trouve
    if (!$user || !Hash::check($request->password, $user->password)) {
        return response()->json(['message' => 'Identifiants incorrects'], 401);
    }

    $token = $user->createToken('auth_token')->plainTextToken;

    return response()->json([
        'token' => $token,
        'user' => $user
    ]);
}
}
