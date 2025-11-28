import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AiAdvisorScreen extends StatefulWidget {
  final bool isLeaseAnalyzer;

  const AiAdvisorScreen({super.key, this.isLeaseAnalyzer = false});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  // TODO: Replace with your actual API Key
  static const String _apiKey = "YOUR_API_KEY_HERE";

  late final GenerativeModel _model;
  late final ChatSession _chat;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Lease Analyzer
  final TextEditingController _leaseController = TextEditingController();
  String _leaseAnalysis = '';

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-pro', apiKey: _apiKey);
    _chat = _model.startChat();

    if (!widget.isLeaseAnalyzer) {
      _messages.add(
        ChatMessage(
          role: 'model',
          text:
              "Hi! I'm RentGenie. Ask me anything about renting, affordability, or negotiation.",
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text));
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      final responseText = response.text;

      if (responseText != null) {
        setState(() {
          _messages.add(ChatMessage(role: 'model', text: responseText));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            role: 'model',
            text:
                "Sorry, I'm having trouble connecting right now. Please check your API Key.",
          ),
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  Future<void> _analyzeLease() async {
    final text = _leaseController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _leaseAnalysis = '';
    });

    try {
      final prompt =
          "Analyze the following lease agreement text for red flags, illegal clauses, and unusual terms:\n\n$text";
      final response = await _model.generateContent([Content.text(prompt)]);

      setState(() {
        _leaseAnalysis = response.text ?? "No analysis generated.";
      });
    } catch (e) {
      setState(() {
        _leaseAnalysis = "Error analyzing lease. Please check your API Key.";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLeaseAnalyzer) {
      return _buildLeaseAnalyzer();
    }
    return _buildChatInterface();
  }

  Widget _buildChatInterface() {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.role == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.white,
                      borderRadius: BorderRadius.circular(12).copyWith(
                        topLeft: isUser
                            ? const Radius.circular(12)
                            : Radius.zero,
                        topRight: isUser
                            ? Radius.zero
                            : const Radius.circular(12),
                      ),
                      boxShadow: isUser
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                              ),
                            ],
                    ),
                    child: MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.inter(
                          color: isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Ask about rent budgets...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: const Icon(LucideIcons.send),
                  color: Colors.indigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseAnalyzer() {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.fileText, color: Colors.purple),
                      const SizedBox(width: 8),
                      Text(
                        'Paste Lease Agreement',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _leaseController,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: 'Paste lease text here...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _analyzeLease,
                      icon: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(LucideIcons.sparkles),
                      label: const Text('Analyze Lease'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_leaseAnalysis.isNotEmpty) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Results',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    MarkdownBody(data: _leaseAnalysis),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String role;
  final String text;
  ChatMessage({required this.role, required this.text});
}
