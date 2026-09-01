import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/udo_design_system.dart';
import '../providers/ai_assistant_provider.dart';

const _aiAccent = Color(0xFF4B4D52);

class AiAssistantChatScreen extends ConsumerStatefulWidget {
  final String? initialPrompt;
  const AiAssistantChatScreen({super.key, this.initialPrompt});

  @override
  ConsumerState<AiAssistantChatScreen> createState() =>
      _AiAssistantChatScreenState();
}

class _AiAssistantChatScreenState extends ConsumerState<AiAssistantChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollController = ScrollController();
  bool _sentInitialPrompt = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _send([String? presetText]) async {
    final text = presetText ?? _ctrl.text;
    if (text.trim().isEmpty) return;
    _ctrl.clear();
    _scrollToBottom();
    final error =
        await ref.read(aiAssistantProvider.notifier).sendMessage(text);
    if (!mounted) return;
    _scrollToBottom();
    if (error != null && !ref.read(aiAssistantProvider).limitReached) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiAssistantProvider);

    if (!_sentInitialPrompt &&
        !state.isLoading &&
        widget.initialPrompt != null &&
        widget.initialPrompt!.trim().isNotEmpty) {
      _sentInitialPrompt = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _send(widget.initialPrompt));
    }

    return Scaffold(
      backgroundColor: UdoDesign.bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: UdoDesign.text,
        title: const Text('Udo AI',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                state.usageLimit == null
                    ? 'Unlimited'
                    : '${state.usageUsed}/${state.usageLimit} this month',
                style: UdoDesign.sans(
                    size: 12,
                    weight: FontWeight.w700,
                    color: state.limitReached
                        ? AppTheme.udoCrimson
                        : UdoDesign.muted),
              ),
            ),
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: state.isLoading
              ? const Center(child: CircularProgressIndicator(color: _aiAccent))
              : state.messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.auto_awesome_outlined,
                              size: 40, color: UdoDesign.muted),
                          const SizedBox(height: 12),
                          Text(
                              'Ask about planning, guests, budget, travel, honeymoon, timelines or seating.',
                              textAlign: TextAlign.center,
                              style: UdoDesign.sans(
                                  size: 13, color: UdoDesign.muted)),
                        ]),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.messages.length,
                      itemBuilder: (_, index) {
                        final log = state.messages[index];
                        final prompt = log['prompt']?.toString() ?? '';
                        final response = log['response']?.toString();
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _ChatBubble(text: prompt, isUser: true),
                              const SizedBox(height: 8),
                              if (response != null)
                                _ChatBubble(text: response, isUser: false)
                              else if (state.isSending &&
                                  index == state.messages.length - 1)
                                const _ChatTypingBubble(),
                              const SizedBox(height: 12),
                            ]);
                      },
                    ),
        ),
        if (state.limitReached)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppTheme.udoCrimson.withValues(alpha: 0.08),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("You've reached this month's Udo AI limit.",
                  style: UdoDesign.sans(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppTheme.udoCrimson)),
              const SizedBox(height: 4),
              Text('Upgrade your plan for more questions each month.',
                  style: UdoDesign.sans(size: 12, color: UdoDesign.sub)),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.udoCrimson,
                    side: const BorderSide(color: AppTheme.udoCrimson)),
                child: const Text('View plans in Billing'),
              ),
            ]),
          )
        else ...[
          if (state.error != null && state.error!.trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.udoPastelCrimson.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppTheme.udoPastelCrimson.withValues(alpha: 0.45)),
              ),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.info_outline,
                    size: 18, color: AppTheme.udoCrimson),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(state.error!,
                      style: UdoDesign.sans(
                          size: 12.5,
                          height: 1.35,
                          color: AppTheme.udoCrimson)),
                ),
              ]),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask Udo AI about your wedding or travel...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: UdoDesign.border)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: UdoDesign.border)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: state.isSending ? null : () => _send(),
                  style: IconButton.styleFrom(backgroundColor: _aiAccent),
                  icon: state.isSending
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.arrow_upward,
                          color: Colors.white, size: 18),
                ),
              ]),
            ),
          ),
        ],
      ]),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  const _ChatBubble({required this.text, required this.isUser});

  @override
  Widget build(BuildContext context) => Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isUser ? AppTheme.udoGreen : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser ? null : Border.all(color: UdoDesign.border),
          ),
          child: Text(text,
              style: UdoDesign.sans(
                  size: 13.5,
                  height: 1.4,
                  color: isUser ? Colors.white : UdoDesign.text)),
        ),
      );
}

class _ChatTypingBubble extends StatelessWidget {
  const _ChatTypingBubble();

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft: Radius.circular(4),
            ),
            border: Border.all(color: UdoDesign.border),
          ),
          child: const SizedBox(
              width: 16,
              height: 16,
              child:
                  CircularProgressIndicator(strokeWidth: 2, color: _aiAccent)),
        ),
      );
}
