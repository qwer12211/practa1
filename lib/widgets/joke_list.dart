import 'package:flutter/material.dart';

import '../services/joke_service.dart';

class JokeList extends StatefulWidget {
  const JokeList({super.key});

  @override
  State<JokeList> createState() => _JokeListState();
}

class _JokeListState extends State<JokeList> {
  final JokeService _jokeService = JokeService();

  List<String> _jokes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadJokes();
  }

  Future<void> _loadJokes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final int count = _jokes.isEmpty ? 1 : _jokes.length;

      final List<String> newJokes = [];

      for (int i = 0; i < count; i++) {
        final jokes = await _jokeService.fetchJokes();
        newJokes.addAll(jokes);
      }

      setState(() {
        _jokes = newJokes;
      });
    } catch (e) {
      debugPrint('Ошибка загрузки шуток: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreJokes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final jokes = await _jokeService.fetchJokes();
      setState(() {
        _jokes.addAll(jokes);
      });
    } catch (e) {
      debugPrint('Ошибка загрузки шуток: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _removeOneJoke() {
    if (_jokes.isEmpty) return;

    setState(() {
      _jokes.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadJokes,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить шутки'),
              ),
              ElevatedButton.icon(
                onPressed: (_isLoading || _jokes.isEmpty)
                    ? null
                    : _removeOneJoke,
                icon: const Icon(Icons.remove),
                label: const Text('Удалить 1'),
              ),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadMoreJokes,
                icon: const Icon(Icons.add),
                label: const Text('Добавить 1'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _jokes.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.mood),
                      title: Text(_jokes[index]),
                      subtitle: const Text('Батя шутит...'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
