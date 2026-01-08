<?php

use App\Http\Controllers\AuthController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\ExpenseController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// Routes publiques
Route::post('/register', [AuthController::class, 'register']);

// Routes protégées (il faut un token)
Route::group(['middleware' => ['auth:sanctum']], function () {
    Route::apiResource('expenses', ExpenseController::class);
});

Route::post('/login', [AuthController::class, 'login']);
