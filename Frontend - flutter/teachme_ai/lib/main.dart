/*
 * Project: TeachMe AI
 * Description: Voice-First Vocational Learning Platform for the Illiterate Workforce.
 * Author: Cynthia Moraa (PLP Alumna)
 * Copyright (c) 2026. All Rights Reserved.
 *
 * This code is proprietary. Unauthorized copying of this file, via any medium is strictly prohibited.
 */

import 'dart:io';  // ← CRITICAL: Added this import for SocketException
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TeachMeAI());
}

class TeachMeAI extends StatelessWidget {
  const TeachMeAI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeachMe AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        primaryColor: Colors.green,
      ),
      home: const ListeningHome(),
    );
  }
}

class ListeningHome extends StatefulWidget {
  const ListeningHome({Key? key}) : super(key: key);

  @override
  State<ListeningHome> createState() => _ListeningHomeState();
}

class _ListeningHomeState extends State<ListeningHome> with SingleTickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late FlutterTts _tts;
  bool _isListening = false;
  bool _isThinking = false;
  String _spokenText = '';
  late AnimationController _thinkingController;
  bool _speechAvailable = false;

  // ============================================================================
  // CONFIGURE YOUR BACKEND URL HERE
  // ============================================================================
  // Choose ONE option based on your setup:
  
  // Option 1: Android Emulator (RECOMMENDED FOR TESTING)
  static const String BACKEND_URL = 'http://10.0.2.2:8000';
  
  // Option 2: iOS Simulator
  // static const String BACKEND_URL = 'http://localhost:8000';
  
  // Option 3: Real Phone on Same WiFi (replace with your computer's IP)
  // static const String BACKEND_URL = 'http://192.168.1.100:8000';
  
  // Option 4: Production Server (after deployment)
  // static const String BACKEND_URL = 'https://your-app.onrender.com';
  // ============================================================================

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _tts = FlutterTts();
    _thinkingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _initializeSpeech();
    await _initializeTTS();
    await _autoGreet();
  }

  Future<void> _initializeSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: (status) {
          if (status == 'done' && _isListening) {
            setState(() => _isListening = false);
            if (_spokenText.isNotEmpty) {
              _processVoiceInput();
            }
          }
        },
        onError: (error) {
          print('❌ Speech error: $error');
          if (mounted) {
            setState(() => _isListening = false);
          }
        },
      );
      print('✅ Speech recognition available: $_speechAvailable');
    } catch (e) {
      print('❌ Error initializing speech: $e');
      _speechAvailable = false;
    }
  }

  Future<void> _initializeTTS() async {
    try {
      // Try Swahili first
      await _tts.setLanguage('sw-KE');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      print('✅ TTS initialized with Swahili');
    } catch (e) {
      print('⚠️ Swahili TTS not available, falling back to English');
      try {
        await _tts.setLanguage('en-US');
      } catch (e2) {
        print('❌ TTS initialization failed: $e2');
      }
    }
  }

  Future<void> _autoGreet() async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _tts.speak('Karibu TeachMe. Hakuna login. Gusa duara na useme Maji au Shamba.');
  }

  void _startListening() async {
    if (!_speechAvailable) {
      await _tts.speak('Samahani, microphone haifanyi kazi.');
      return;
    }

    if (!_isListening) {
      setState(() {
        _isListening = true;
        _spokenText = '';
      });

      try {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _spokenText = result.recognizedWords;
            });
            print('🎤 Recognized: $_spokenText');
            // Update in real-time even for partial results
            if (result.finalResult) {
              print('✅ Final result: ${result.recognizedWords}');
            }
          },
          localeId: 'sw_KE', // Swahili Kenya
          listenFor: const Duration(seconds: 5),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          cancelOnError: true,
          listenMode: stt.ListenMode.confirmation,
        );
      } catch (e) {
        print('❌ Listen error: $e');
        setState(() => _isListening = false);
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      _speech.stop();
      setState(() => _isListening = false);
      if (_spokenText.isNotEmpty) {
        _processVoiceInput();
      }
    }
  }

  Future<void> _processVoiceInput() async {
    if (_spokenText.trim().isEmpty) {
      await _tts.speak('Sikukusikia. Jaribu tena.');
      return;
    }

    setState(() => _isThinking = true);

    try {
      print('📤 Sending to backend: $_spokenText');
      print('🔗 URL: $BACKEND_URL/process-voice');

      final response = await http.post(
        Uri.parse('$BACKEND_URL/process-voice'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'spoken_text': _spokenText}),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Server timeout after 10 seconds');
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final videoId = data['video_id'] as String?;
        final voiceReply = data['voice_reply'] as String?;

        print('✅ Got response: video_id=$videoId, reply=$voiceReply');

        // CRITICAL: Check if video_id exists and is valid
        if (videoId != null && videoId.isNotEmpty && videoId != '') {
          print('✅ Valid video ID: $videoId');

          // Speak response
          if (voiceReply != null && voiceReply.isNotEmpty) {
            await _tts.speak(voiceReply);
            await Future.delayed(const Duration(seconds: 2));
          }

          // FORCE navigation to video - this is critical
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(videoId: videoId),
              ),
            ).then((_) {
              // Reset and greet again
              _autoGreet();
            });
          } else {
            throw Exception('Widget not mounted for navigation');
          }
        } else {
          // No valid video ID - speak error message
          print('❌ Invalid or missing video_id in response');
          await _tts.speak('Sikupata hiyo. Jaribu tena.');
        }
      } else {
        // Server error - speak error message
        print('❌ Server error: ${response.statusCode}');
        await _tts.speak('Sikupata hiyo. Jaribu tena.');
      }
    } on TimeoutException catch (e) {
      print('⏱️ Timeout: $e');
      await _tts.speak('Mtandao ni polepole. Jaribu tena.');
    } on SocketException catch (e) {
      print('🌐 Network error: $e');
      await _tts.speak('Hakuna mtandao. Washa data yako.');
    } catch (e) {
      print('❌ Error: $e');
      // Ensure we always give feedback
      await _tts.speak('Sikupata hiyo. Jaribu tena.');
    } finally {
      if (mounted) {
        setState(() {
          _isThinking = false;
          _spokenText = '';
        });
      }
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _speech.stop();
    _tts.stop();
    _thinkingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF1D1E33)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: _isThinking ? _buildThinkingAnimation() : _buildListeningButton(),
          ),
        ),
      ),
    );
  }

  Widget _buildListeningButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _isListening ? _stopListening : _startListening,
          child: AvatarGlow(
            glowColor: _isListening ? Colors.red : Colors.green,
            endRadius: 200.0,
            duration: const Duration(milliseconds: 2000),
            repeat: true,
            showTwoGlows: true,
            repeatPauseDuration: const Duration(milliseconds: 100),
            child: Material(
              elevation: 8.0,
              shape: const CircleBorder(),
              color: Colors.transparent,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.red.shade700 : Colors.green.shade600,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.green).withOpacity(0.5),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        // DEBUG TEXT: Show real-time recognition
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.blue.withOpacity(0.5), width: 1),
          ),
          child: Text(
            _spokenText.isNotEmpty 
                ? "Heard: '$_spokenText'" 
                : _isListening 
                    ? "Listening..." 
                    : "Tap to speak",
            style: TextStyle(
              color: Colors.blue.shade200,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (_spokenText.isNotEmpty) ...[
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Text(
              _spokenText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildThinkingAnimation() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _thinkingController,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.blue, width: 8),
              gradient: const SweepGradient(
                colors: [Colors.blue, Colors.transparent],
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.psychology, size: 40, color: Colors.blue),
        ),
      ],
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;
  late FlutterTts _tts;
  Timer? _paywallTimer;
  bool _showPaywall = false;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts();
    _initializeTTS();

    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        loop: false,
      ),
    );

    _paywallTimer = Timer(const Duration(seconds: 15), _showPaywallDialog);
  }

  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage('sw-KE');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
    } catch (e) {
      await _tts.setLanguage('en-US');
    }
  }

  void _showPaywallDialog() {
    if (mounted) {
      _controller.pause();
      setState(() => _showPaywall = true);
      _tts.speak('Kumaliza somo hili, lipa shilingi kumi.');
    }
  }

  void _handlePayment() async {
    _tts.speak('Inganisha M-Pesa yako.');
    
    // Simulate payment success (replace with real M-Pesa integration)
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() => _showPaywall = false);
      _controller.play();
      _tts.speak('Asante. Endelea kusoma.');
    }
  }

  @override
  void dispose() {
    _paywallTimer?.cancel();
    _controller.dispose();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: YoutubePlayer(
              controller: _controller,
              showVideoProgressIndicator: true,
              progressIndicatorColor: Colors.green,
              progressColors: const ProgressBarColors(
                playedColor: Colors.green,
                handleColor: Colors.greenAccent,
              ),
            ),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.shade600,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.close, size: 40, color: Colors.white),
              ),
            ),
          ),
          if (_showPaywall)
            Container(
              color: Colors.black.withOpacity(0.95),
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade700,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.lock, size: 100, color: Colors.white),
                      ),
                      const SizedBox(height: 50),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone_android, size: 60, color: Colors.white),
                            SizedBox(width: 20),
                            Icon(Icons.attach_money, size: 60, color: Colors.white),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: const Text(
                          '10 KES',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      GestureDetector(
                        onTap: _handlePayment,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 25),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.touch_app, size: 70, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                          child: const Icon(Icons.close, size: 40, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}