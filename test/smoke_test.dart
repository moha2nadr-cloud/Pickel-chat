import 'package:flutter_test/flutter_test.dart';

import 'package:pickle_chat/core/constants/app_constants.dart';
import 'package:pickle_chat/core/utils/markdown_helper.dart';
import 'package:pickle_chat/data/models/conversation_model.dart';

void main() {
  group('ConversationModel.titleFromText', () {
    test('returns fallback for empty text', () {
      expect(ConversationModel.titleFromText('   '), 'New Chat');
    });

    test('truncates long titles', () {
      final input = 'a' * 60;
      final title = ConversationModel.titleFromText(input);
      expect(title.length, AppConstants.conversationTitleMaxLength + 3);
      expect(title.endsWith('...'), isTrue);
    });
  });

  group('MarkdownHelper.appendCursor', () {
    test('adds cursor in streaming state', () {
      expect(MarkdownHelper.appendCursor('hello', true), 'hello▍');
    });

    test('keeps content as-is when not streaming', () {
      expect(MarkdownHelper.appendCursor('hello', false), 'hello');
    });
  });
}
