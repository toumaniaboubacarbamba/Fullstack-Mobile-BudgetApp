<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Expense;


class ExpenseController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index(Request $request)
    {
        // On récupère que les dépenses de l'utilisateur authentifié
    return response()->json($request->user()->expenses);
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
{
    $validated = $request->validate([
        'title' => 'required|string',
        'amount' => 'required|numeric',
        'category' => 'required|string',
    ]);

    // On crée la dépense à travers la relation de l'utilisateur
    $expense = $request->user()->expenses()->create($validated);

    return response()->json($expense, 201);
}

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Expense $expense)
{
    $expense->delete();
    return response()->json(['message' => 'Supprimé avec succès']);
}
}
