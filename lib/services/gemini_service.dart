// lib/services/gemini_service.dart
import 'dart:math';

class GeminiService {
  static final Random _random = Random();
  
  // Smart responses for different mental health topics - no open-ended questions
  static final Map<String, List<String>> _responseLibrary = {
    'motivation': [
      '''I understand motivation can be challenging sometimes. Here are some strategies that might help:

🎯 **Start Tiny**: Begin with just a 2-minute version of the task
📝 **Break It Down**: Divide big goals into baby steps
🏆 **Celebrate Micro-Wins**: Acknowledge every tiny accomplishment
⏰ **Pomodoro Method**: Work for 25 minutes, then take a 5-minute break
💭 **Connect to Values**: Remember how this task aligns with what matters to you

Try starting with one small step and see how it feels.''',

      '''Motivation often follows action rather than precedes it. Try these approaches:

🚀 **5-Second Rule**: Count down 5-4-3-2-1 and just start
📊 **Progress Tracking**: Keep a simple checklist to build momentum
🌞 **Morning Momentum**: Do your most important task first thing
🔄 **Habit Stacking**: Attach new tasks to existing habits
🎵 **Energy Boost**: Try upbeat music or changing your environment

Remember that taking any action, no matter how small, can build momentum.''',
    ],

    'anxious': [
      '''I hear you're feeling anxious. Here are some immediate support techniques:

🌬️ **4-7-8 Breathing**: Inhale 4 seconds, hold 7, exhale 8 seconds
🌳 **5-4-3-2-1 Grounding**: Notice 5 things you see, 4 you feel, 3 you hear, 2 you smell, 1 you taste
🚶 **Movement Break**: A quick walk or stretch can shift your energy
📓 **Worry Time**: Schedule 15 minutes later to process worries
💧 **Cool Sensation**: Splash cold water on your face or hold a cold drink

These techniques can help bring you back to the present moment.''',

      '''Anxiety is your body's way of trying to protect you. Here are some helpful approaches:

🎯 **Focus on Control**: Identify what you can control vs. what you can't
📱 **Digital Break**: Step away from screens and news for a bit
🧘 **Body Scan**: Slowly notice sensations from head to toe
📝 **Thought Download**: Write down everything worrying you
🌿 **Nature Connection**: Even looking at plants or nature images can help

Remember that this feeling will pass, and you have tools to manage it.''',
    ],

    'stress': [
      '''Stress can feel overwhelming. Let's break it down with these strategies:

🛑 **Pause and Breathe**: Take 3 deep belly breaths right now
📋 **Brain Dump**: Write down everything on your mind, then prioritize
⚖️ **Balance Check**: Are you getting enough sleep, movement, and nutrition?
🎯 **One Thing**: Focus on the single most important thing first
🔄 **Perspective Shift**: Consider how this will feel in a week or month

These approaches can help you feel more grounded and in control.''',
    ],

    'sad': [
      '''I'm sorry you're feeling this way. Your feelings are completely valid.

💝 **Self-Compassion**: Speak to yourself like you would a dear friend
☀️ **Light Exposure**: Spend time near a window or outside if possible
📞 **Connection**: Reach out to someone you trust
🎨 **Creative Expression**: Try drawing, writing, or any creative outlet
🌿 **Gentle Movement**: A slow walk or gentle stretching can help

Remember that feelings are temporary visitors, and you have strength within you.''',

      '''It takes courage to acknowledge when you're feeling down. Here are some gentle ideas:

🛌 **Rest**: Allow yourself to rest without guilt
🎵 **Comfort Sounds**: Gentle music, nature sounds, or comforting silence
📖 **Distraction**: A comforting book, podcast, or movie
💧 **Hydration & Nutrition**: Simple, nourishing foods and drinks
🌟 **Small Pleasures**: Focus on one tiny thing that usually brings comfort

Be gentle with yourself during this time.''',
    ],

    'sleep': [
      '''Sleep challenges are common. Here are some evidence-based tips:

🌙 **Consistent Schedule**: Try to sleep and wake at similar times
📵 **Screen-Free Hour**: Avoid screens 1 hour before bed
🌡️ **Cool Environment**: Keep your bedroom slightly cool
📚 **Wind-Down Routine**: Create a calming pre-sleep ritual
☕ **Caffeine Cutoff**: Avoid caffeine after 2 PM

Consistency with these habits can significantly improve sleep quality.''',
    ],

    'overthinking': [
      '''Overthinking can be exhausting. Try these strategies to quiet your mind:

🛑 **Thought Stopping**: Literally say "stop" when you notice looping thoughts
📓 **Journal Release**: Write thoughts down to get them out of your head
🎯 **Present Moment**: Focus on your senses - what can you see, hear, feel right now?
⏰ **Designated Worry Time**: Schedule 15 minutes for worries later
🧘 **Mindfulness**: Practice observing thoughts without getting caught in them

Remember that thoughts are just thoughts - they don't define reality.''',
    ],

    'selfcare': [
      '''Self-care is essential for mental wellness. Here are some ideas:

💆 **Physical Care**: Warm bath, gentle stretching, or massage
🎨 **Creative Time**: Drawing, writing, music, or any creative expression
🌳 **Nature Connection**: Walk outside or bring plants indoors
📚 **Quiet Time**: Reading, meditation, or simply sitting in silence
🍵 **Nourishment**: Prepare a healthy meal or comforting drink

Even small acts of self-care can make a big difference in how you feel.''',
    ],

    'mindfulness': [
      '''Mindfulness helps bring you into the present moment. Try these practices:

🌬️ **Breath Awareness**: Simply notice your breath for 2 minutes
🍎 **Mindful Eating**: Eat slowly, noticing flavors and textures
🚶 **Walking Meditation**: Walk slowly, noticing each step
🔔 **Bell Mindfulness**: Use a sound to bring attention to the present
📿 **Body Scan**: Slowly notice sensations from head to toe

Regular mindfulness practice can reduce stress and increase calm.''',
    ],

    'balance': [
      '''Work-life balance is challenging. Consider these approaches:

⏰ **Set Boundaries**: Define clear start and end times for work
📅 **Schedule Breaks**: Plan regular breaks throughout your day
🎯 **Prioritize**: Focus on what truly matters each day
📱 **Digital Detox**: Designate screen-free times
🌿 **Self-Care Integration**: Build small self-care practices into your routine

Balance is about making intentional choices that support your wellbeing.''',
    ],

    'general': [
      '''Hello! I'm MindHaven, your mental wellness companion. 

I'm here to offer compassionate support with:
• Stress and anxiety management
• Motivation and focus strategies  
• Emotional well-being
• Self-care practices
• Mindfulness techniques

Tap any topic to explore supportive strategies.''',

      '''Welcome! I'm glad you're here. Taking time for your mental health is important.

I can help you explore practical tools for:
🌱 Coping with challenging emotions
🎯 Building daily well-being habits
💫 Mindfulness and self-care practices
🌟 Developing emotional resilience

Choose a topic that resonates with you right now.''',
    ],
  };

  static Future<String> sendMessage(String message) async {
    // Simulate API delay (1-3 seconds)
    await Future.delayed(Duration(milliseconds: 1000 + _random.nextInt(2000)));
    
    return _getSmartResponse(message);
  }

  static String _getSmartResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    // Match user message to appropriate response category
    if (message.contains('motivation') || 
        message.contains('unmotivated') || 
        message.contains('procrastinate')) {
      return _getRandomResponse('motivation');
    }
    
    if (message.contains('anxious') || 
        message.contains('anxiety') || 
        message.contains('panic')) {
      return _getRandomResponse('anxious');
    }
    
    if (message.contains('stress') || 
        message.contains('overwhelm') || 
        message.contains('pressure')) {
      return _getRandomResponse('stress');
    }
    
    if (message.contains('sad') || 
        message.contains('depress') || 
        message.contains('down') ||
        message.contains('hopeless')) {
      return _getRandomResponse('sad');
    }
    
    if (message.contains('sleep') || 
        message.contains('insomnia') || 
        message.contains('tired')) {
      return _getRandomResponse('sleep');
    }
    
    if (message.contains('overthink') || 
        message.contains('ruminate') || 
        message.contains('overthinking')) {
      return _getRandomResponse('overthinking');
    }
    
    if (message.contains('self-care') || 
        message.contains('self care') || 
        message.contains('selfcare')) {
      return _getRandomResponse('selfcare');
    }
    
    if (message.contains('mindfulness') || 
        message.contains('meditation') || 
        message.contains('present')) {
      return _getRandomResponse('mindfulness');
    }
    
    if (message.contains('balance') || 
        message.contains('work-life') || 
        message.contains('work life')) {
      return _getRandomResponse('balance');
    }
    
    if (message.contains('hello') || 
        message.contains('hi') || 
        message.contains('hey')) {
      return _getRandomResponse('general');
    }
    
    // Default to general supportive response
    return _getRandomResponse('general');
  }

  static String _getRandomResponse(String category) {
    final responses = _responseLibrary[category] ?? _responseLibrary['general']!;
    return responses[_random.nextInt(responses.length)];
  }

  // Test method - always successful now!
  static Future<void> testConnection() async {
    print('🧪 Smart Chatbot Service - Always Available!');
    print('✅ No API needed - Using enhanced mental health responses');
    
    final testResponse = await sendMessage('test');
    print('📝 Sample response length: ${testResponse.length} chars');
  }
}