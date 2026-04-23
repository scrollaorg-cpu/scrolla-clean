import 'package:flutter/material.dart';
import 'package:scrolla/services/bible_api_service.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final _query = TextEditingController(text: 'John 3:16');
  final _service = BibleApiService();

  bool loading = false;
  String? error;
  VerseResult? result;

  @override
  void initState() {
    super.initState();
    _load(_query.text);
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _load(String q) async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final r = await _service.getPassage(q, translation: 'web');
      setState(() => result = r);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Read a passage', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _query,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _load,
                    decoration: InputDecoration(
                      labelText: 'Reference (e.g. John 3:16, Psalm 23)',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () => _load(_query.text),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      FilledButton(
                        onPressed: loading ? null : () => _load(_query.text),
                        child: Text(loading ? 'Loading...' : 'Read'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton(
                        onPressed: () {
                          _query.text = 'Psalm 23';
                          _load(_query.text);
                        },
                        child: const Text('Psalm 23'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),

          if (error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            ),

          if (result != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result!.reference,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(result!.text, style: const TextStyle(fontSize: 16, height: 1.35)),
                    const SizedBox(height: 10),
                    Text(
                      '— ${(result!.translation ?? '').toUpperCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}