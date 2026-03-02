<?php

namespace App\Http\Controllers;

use App\Models\Favorite;
use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    // GET /api/favorites — liste des favoris de l'utilisateur connecté
    public function index(Request $request)
    {
        $favorites = $request->user()->favorites()->get();
        return response()->json($favorites);
    }

    // POST /api/favorites — ajouter ou retirer un favori
    public function toggle(Request $request)
    {
        $request->validate([
            'movie_id'     => 'required|integer',
            'title'        => 'required|string',
            'overview'     => 'nullable|string',
            'poster_path'  => 'nullable|string',
            'vote_average' => 'nullable|numeric',
        ]);

        $existing = Favorite::where('user_id', $request->user()->id)
            ->where('movie_id', $request->movie_id)
            ->first();

        if ($existing) {
            // Film déjà en favori → on le retire
            $existing->delete();
            return response()->json([
                'is_favorite' => false,
                'message'     => 'Retiré des favoris',
            ]);
        }

        // Film pas encore en favori → on l'ajoute
        Favorite::create([
            'user_id'      => $request->user()->id,
            'movie_id'     => $request->movie_id,
            'title'        => $request->title,
            'overview'     => $request->overview,
            'poster_path'  => $request->poster_path,
            'vote_average' => $request->vote_average,
        ]);

        return response()->json([
            'is_favorite' => true,
            'message'     => 'Ajouté aux favoris',
        ]);
    }
}
