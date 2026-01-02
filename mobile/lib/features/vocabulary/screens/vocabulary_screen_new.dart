import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/services/user_journey_service.dart';

// Vocabulary word model
class VocabWord {
  final String word;
  final String pronunciation;
  final String partOfSpeech;
  final String definition;
  final String example;
  final List<String> synonyms;
  final String difficulty;
  final int masteryLevel;
  bool isFavorite;
  bool isLearned;

  VocabWord({
    required this.word,
    required this.pronunciation,
    required this.partOfSpeech,
    required this.definition,
    required this.example,
    this.synonyms = const [],
    required this.difficulty,
    this.masteryLevel = 0,
    this.isFavorite = false,
    this.isLearned = false,
  });
}

// Vocabulary categories
class VocabCategory {
  final String name;
  final String emoji;
  final Color color;
  final List<VocabWord> words;

  const VocabCategory({
    required this.name,
    required this.emoji,
    required this.color,
    required this.words,
  });
}

// Sample vocabulary data - Expanded with 15+ words per category, including advanced vocabulary
final _vocabCategories = [
  VocabCategory(
    name: 'Essential Verbs',
    emoji: '⚡',
    color: const Color(0xFF6C5CE7),
    words: [
      VocabWord(
        word: 'Accomplish',
        pronunciation: '/əˈkɒmplɪʃ/',
        partOfSpeech: 'verb',
        definition: 'To successfully complete or achieve something',
        example: 'She accomplished all her goals for the year.',
        synonyms: ['achieve', 'complete', 'fulfill'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Demonstrate',
        pronunciation: '/ˈdemənstreɪt/',
        partOfSpeech: 'verb',
        definition: 'To show or prove something clearly',
        example: 'The experiment demonstrates the principle.',
        synonyms: ['show', 'prove', 'illustrate'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Elaborate',
        pronunciation: '/ɪˈlæbəreɪt/',
        partOfSpeech: 'verb',
        definition: 'To explain or describe in more detail',
        example: 'Could you elaborate on your idea?',
        synonyms: ['expand', 'explain', 'develop'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Persevere',
        pronunciation: '/ˌpɜːsɪˈvɪə/',
        partOfSpeech: 'verb',
        definition: 'To continue despite difficulties',
        example: 'She persevered through all challenges.',
        synonyms: ['persist', 'endure', 'continue'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Contemplate',
        pronunciation: '/ˈkɒntəmpleɪt/',
        partOfSpeech: 'verb',
        definition: 'To think about something carefully',
        example: 'He contemplated his next move.',
        synonyms: ['consider', 'ponder', 'reflect'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ameliorate',
        pronunciation: '/əˈmiːliəreɪt/',
        partOfSpeech: 'verb',
        definition: 'To make something better or more tolerable',
        example: 'The new policies ameliorated working conditions.',
        synonyms: ['improve', 'enhance', 'better'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Exacerbate',
        pronunciation: '/ɪɡˈzæsəbeɪt/',
        partOfSpeech: 'verb',
        definition: 'To make a problem or situation worse',
        example: 'His comments exacerbated the tension.',
        synonyms: ['worsen', 'aggravate', 'intensify'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Elucidate',
        pronunciation: '/ɪˈluːsɪdeɪt/',
        partOfSpeech: 'verb',
        definition: 'To make something clear by explaining it',
        example: 'The professor elucidated the complex theory.',
        synonyms: ['clarify', 'explain', 'illuminate'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Corroborate',
        pronunciation: '/kəˈrɒbəreɪt/',
        partOfSpeech: 'verb',
        definition: 'To confirm or support with evidence',
        example: 'The witness corroborated her testimony.',
        synonyms: ['confirm', 'verify', 'substantiate'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Mitigate',
        pronunciation: '/ˈmɪtɪɡeɪt/',
        partOfSpeech: 'verb',
        definition: 'To make less severe or serious',
        example: 'Steps were taken to mitigate the risks.',
        synonyms: ['alleviate', 'reduce', 'lessen'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Facilitate',
        pronunciation: '/fəˈsɪlɪteɪt/',
        partOfSpeech: 'verb',
        definition: 'To make an action or process easier',
        example: 'Technology facilitates communication.',
        synonyms: ['enable', 'assist', 'expedite'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Proliferate',
        pronunciation: '/prəˈlɪfəreɪt/',
        partOfSpeech: 'verb',
        definition: 'To increase rapidly in number or spread',
        example: 'Social media platforms have proliferated.',
        synonyms: ['multiply', 'spread', 'expand'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Substantiate',
        pronunciation: '/səbˈstænʃieɪt/',
        partOfSpeech: 'verb',
        definition: 'To provide evidence to prove something',
        example: 'He could not substantiate his claims.',
        synonyms: ['prove', 'verify', 'confirm'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Circumvent',
        pronunciation: '/ˌsɜːkəmˈvent/',
        partOfSpeech: 'verb',
        definition: 'To find a way around an obstacle or rule',
        example: 'They tried to circumvent the regulations.',
        synonyms: ['bypass', 'avoid', 'evade'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Disseminate',
        pronunciation: '/dɪˈsemɪneɪt/',
        partOfSpeech: 'verb',
        definition: 'To spread information widely',
        example: 'The news was disseminated quickly.',
        synonyms: ['spread', 'distribute', 'broadcast'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Amalgamate',
        pronunciation: '/əˈmælɡəmeɪt/',
        partOfSpeech: 'verb',
        definition: 'To combine or unite to form one structure',
        example: 'The two companies amalgamated last year.',
        synonyms: ['merge', 'combine', 'unite'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Obfuscate',
        pronunciation: '/ˈɒbfʌskeɪt/',
        partOfSpeech: 'verb',
        definition: 'To make something unclear or confusing',
        example: 'The lawyer tried to obfuscate the facts.',
        synonyms: ['confuse', 'obscure', 'muddle'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Capitulate',
        pronunciation: '/kəˈpɪtʃʊleɪt/',
        partOfSpeech: 'verb',
        definition: 'To surrender or give in to demands',
        example: 'The army was forced to capitulate.',
        synonyms: ['surrender', 'yield', 'submit'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Extricate',
        pronunciation: '/ˈekstrɪkeɪt/',
        partOfSpeech: 'verb',
        definition: 'To free from a difficult situation',
        example: 'She managed to extricate herself from the argument.',
        synonyms: ['free', 'release', 'disentangle'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Insinuate',
        pronunciation: '/ɪnˈsɪnjueɪt/',
        partOfSpeech: 'verb',
        definition: 'To suggest something indirectly',
        example: 'Are you insinuating that I lied?',
        synonyms: ['imply', 'suggest', 'hint'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Perpetuate',
        pronunciation: '/pəˈpetʃueɪt/',
        partOfSpeech: 'verb',
        definition: 'To make something continue indefinitely',
        example: 'Myths perpetuate false beliefs.',
        synonyms: ['continue', 'maintain', 'preserve'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Relinquish',
        pronunciation: '/rɪˈlɪŋkwɪʃ/',
        partOfSpeech: 'verb',
        definition: 'To voluntarily give up or release',
        example: 'He relinquished control of the company.',
        synonyms: ['surrender', 'abandon', 'renounce'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Supplant',
        pronunciation: '/səˈplɑːnt/',
        partOfSpeech: 'verb',
        definition: 'To replace someone or something',
        example: 'Digital cameras supplanted film cameras.',
        synonyms: ['replace', 'supersede', 'displace'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Vindicate',
        pronunciation: '/ˈvɪndɪkeɪt/',
        partOfSpeech: 'verb',
        definition: 'To clear of blame or prove right',
        example: 'The evidence vindicated the accused.',
        synonyms: ['justify', 'exonerate', 'absolve'],
        difficulty: 'Advanced',
      ),
    ],
  ),
  VocabCategory(
    name: 'Descriptive Words',
    emoji: '🎨',
    color: const Color(0xFFE17055),
    words: [
      VocabWord(
        word: 'Magnificent',
        pronunciation: '/mæɡˈnɪfɪsənt/',
        partOfSpeech: 'adjective',
        definition: 'Extremely beautiful, impressive, or excellent',
        example: 'The view from the mountain was magnificent.',
        synonyms: ['splendid', 'grand', 'stunning'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Peculiar',
        pronunciation: '/pɪˈkjuːliə/',
        partOfSpeech: 'adjective',
        definition: 'Strange or unusual in an interesting way',
        example: 'She has a peculiar sense of humor.',
        synonyms: ['strange', 'odd', 'unusual'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Serene',
        pronunciation: '/sɪˈriːn/',
        partOfSpeech: 'adjective',
        definition: 'Calm, peaceful, and untroubled',
        example: 'The lake was serene in the morning.',
        synonyms: ['peaceful', 'tranquil', 'calm'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Resilient',
        pronunciation: '/rɪˈzɪliənt/',
        partOfSpeech: 'adjective',
        definition: 'Able to recover quickly from difficulties',
        example: 'Children are often incredibly resilient.',
        synonyms: ['tough', 'adaptable', 'strong'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ubiquitous',
        pronunciation: '/juːˈbɪkwɪtəs/',
        partOfSpeech: 'adjective',
        definition: 'Present or found everywhere',
        example: 'Smartphones have become ubiquitous.',
        synonyms: ['everywhere', 'universal', 'omnipresent'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ephemeral',
        pronunciation: '/ɪˈfemərəl/',
        partOfSpeech: 'adjective',
        definition: 'Lasting for a very short time',
        example: 'Fame can be ephemeral in the digital age.',
        synonyms: ['fleeting', 'transient', 'temporary'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ostentatious',
        pronunciation: '/ˌɒstenˈteɪʃəs/',
        partOfSpeech: 'adjective',
        definition: 'Designed to impress or attract attention',
        example: 'The mansion was ostentatious in its design.',
        synonyms: ['showy', 'flashy', 'pretentious'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Meticulous',
        pronunciation: '/məˈtɪkjʊləs/',
        partOfSpeech: 'adjective',
        definition: 'Showing great attention to detail',
        example: 'She is meticulous in her research.',
        synonyms: ['thorough', 'careful', 'precise'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Ambiguous',
        pronunciation: '/æmˈbɪɡjuəs/',
        partOfSpeech: 'adjective',
        definition: 'Open to more than one interpretation',
        example: 'The message was deliberately ambiguous.',
        synonyms: ['unclear', 'vague', 'equivocal'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Eloquent',
        pronunciation: '/ˈeləkwənt/',
        partOfSpeech: 'adjective',
        definition: 'Fluent or persuasive in speaking or writing',
        example: 'She gave an eloquent speech at the ceremony.',
        synonyms: ['articulate', 'expressive', 'fluent'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Pragmatic',
        pronunciation: '/præɡˈmætɪk/',
        partOfSpeech: 'adjective',
        definition: 'Dealing with things realistically and practically',
        example: 'We need a pragmatic approach to this problem.',
        synonyms: ['practical', 'realistic', 'sensible'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Inconspicuous',
        pronunciation: '/ˌɪnkənˈspɪkjuəs/',
        partOfSpeech: 'adjective',
        definition: 'Not clearly visible or attracting attention',
        example: 'He tried to remain inconspicuous in the crowd.',
        synonyms: ['unnoticeable', 'discreet', 'subtle'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Quintessential',
        pronunciation: '/ˌkwɪntɪˈsenʃəl/',
        partOfSpeech: 'adjective',
        definition: 'Representing the perfect example of something',
        example: 'Paris is the quintessential romantic city.',
        synonyms: ['typical', 'classic', 'ideal'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Tenacious',
        pronunciation: '/tɪˈneɪʃəs/',
        partOfSpeech: 'adjective',
        definition: 'Holding firmly to something; persistent',
        example: 'Her tenacious spirit helped her succeed.',
        synonyms: ['persistent', 'determined', 'resolute'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Convoluted',
        pronunciation: '/ˈkɒnvəluːtɪd/',
        partOfSpeech: 'adjective',
        definition: 'Extremely complex and difficult to follow',
        example: 'The plot of the movie was too convoluted.',
        synonyms: ['complicated', 'intricate', 'complex'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Gregarious',
        pronunciation: '/ɡrɪˈɡeəriəs/',
        partOfSpeech: 'adjective',
        definition: 'Fond of company; sociable',
        example: 'She has a gregarious personality.',
        synonyms: ['sociable', 'outgoing', 'friendly'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Lethargic',
        pronunciation: '/lɪˈθɑːdʒɪk/',
        partOfSpeech: 'adjective',
        definition: 'Lacking energy or enthusiasm',
        example: 'The hot weather made everyone lethargic.',
        synonyms: ['sluggish', 'drowsy', 'tired'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Arduous',
        pronunciation: '/ˈɑːdjuəs/',
        partOfSpeech: 'adjective',
        definition: 'Involving great effort; difficult',
        example: 'The climb was arduous but rewarding.',
        synonyms: ['difficult', 'strenuous', 'laborious'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Clandestine',
        pronunciation: '/klænˈdestɪn/',
        partOfSpeech: 'adjective',
        definition: 'Kept secret; done in secrecy',
        example: 'They had a clandestine meeting.',
        synonyms: ['secret', 'covert', 'hidden'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Fastidious',
        pronunciation: '/fæˈstɪdiəs/',
        partOfSpeech: 'adjective',
        definition: 'Very attentive to detail; fussy',
        example: 'He is fastidious about cleanliness.',
        synonyms: ['meticulous', 'fussy', 'particular'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Impeccable',
        pronunciation: '/ɪmˈpekəbl/',
        partOfSpeech: 'adjective',
        definition: 'Without fault; flawless',
        example: 'Her taste in fashion is impeccable.',
        synonyms: ['flawless', 'perfect', 'faultless'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Nefarious',
        pronunciation: '/nɪˈfeəriəs/',
        partOfSpeech: 'adjective',
        definition: 'Wicked or criminal',
        example: 'The villain had nefarious plans.',
        synonyms: ['evil', 'wicked', 'sinister'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Pernicious',
        pronunciation: '/pəˈnɪʃəs/',
        partOfSpeech: 'adjective',
        definition: 'Harmful in a subtle way',
        example: 'Gossip can have pernicious effects.',
        synonyms: ['harmful', 'destructive', 'damaging'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Voracious',
        pronunciation: '/vəˈreɪʃəs/',
        partOfSpeech: 'adjective',
        definition: 'Having a huge appetite; eager',
        example: 'She is a voracious reader.',
        synonyms: ['insatiable', 'greedy', 'eager'],
        difficulty: 'Intermediate',
      ),
    ],
  ),
  VocabCategory(
    name: 'Academic Words',
    emoji: '📚',
    color: const Color(0xFF2E86AB),
    words: [
      VocabWord(
        word: 'Hypothesis',
        pronunciation: '/haɪˈpɒθəsɪs/',
        partOfSpeech: 'noun',
        definition: 'A proposed explanation for something',
        example: 'The scientist tested her hypothesis.',
        synonyms: ['theory', 'assumption', 'premise'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Paradigm',
        pronunciation: '/ˈpærədaɪm/',
        partOfSpeech: 'noun',
        definition: 'A typical example or pattern of something',
        example: 'This represents a paradigm shift in thinking.',
        synonyms: ['model', 'pattern', 'example'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Synthesis',
        pronunciation: '/ˈsɪnθəsɪs/',
        partOfSpeech: 'noun',
        definition: 'Combination of parts to form a whole',
        example: 'The paper provides a synthesis of research.',
        synonyms: ['combination', 'blend', 'fusion'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Empirical',
        pronunciation: '/ɪmˈpɪrɪkəl/',
        partOfSpeech: 'adjective',
        definition: 'Based on observation or experience',
        example: 'We need empirical evidence to support this.',
        synonyms: ['observed', 'experimental', 'practical'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Methodology',
        pronunciation: '/ˌmeθəˈdɒlədʒi/',
        partOfSpeech: 'noun',
        definition: 'A system of methods used in a field',
        example: 'The research methodology was rigorous.',
        synonyms: ['method', 'approach', 'system'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Epistemology',
        pronunciation: '/ɪˌpɪstɪˈmɒlədʒi/',
        partOfSpeech: 'noun',
        definition: 'The theory of knowledge and understanding',
        example: 'Epistemology examines how we know what we know.',
        synonyms: ['philosophy', 'cognition', 'theory'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Juxtaposition',
        pronunciation: '/ˌdʒʌkstəpəˈzɪʃən/',
        partOfSpeech: 'noun',
        definition: 'Placing two things close together for contrast',
        example: 'The artist uses juxtaposition of colors.',
        synonyms: ['contrast', 'comparison', 'placement'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Dichotomy',
        pronunciation: '/daɪˈkɒtəmi/',
        partOfSpeech: 'noun',
        definition: 'A division into two contrasting parts',
        example: 'The dichotomy between work and life balance.',
        synonyms: ['division', 'split', 'contrast'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Antithesis',
        pronunciation: '/ænˈtɪθəsɪs/',
        partOfSpeech: 'noun',
        definition: 'The exact opposite of something',
        example: 'His behavior was the antithesis of kindness.',
        synonyms: ['opposite', 'contrary', 'reverse'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Axiom',
        pronunciation: '/ˈæksiəm/',
        partOfSpeech: 'noun',
        definition: 'A statement accepted as true without proof',
        example: 'It is an axiom of geometry.',
        synonyms: ['principle', 'truth', 'maxim'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Postulate',
        pronunciation: '/ˈpɒstjʊleɪt/',
        partOfSpeech: 'verb',
        definition: 'To suggest or assume as a basis for reasoning',
        example: 'The theory postulates a new mechanism.',
        synonyms: ['propose', 'assume', 'hypothesize'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Correlate',
        pronunciation: '/ˈkɒrəleɪt/',
        partOfSpeech: 'verb',
        definition: 'To have a mutual relationship or connection',
        example: 'Income correlates with education level.',
        synonyms: ['connect', 'relate', 'associate'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Extrapolate',
        pronunciation: '/ɪkˈstræpəleɪt/',
        partOfSpeech: 'verb',
        definition: 'To extend knowledge into an unknown area',
        example: 'We can extrapolate future trends from the data.',
        synonyms: ['infer', 'deduce', 'project'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Cognizant',
        pronunciation: '/ˈkɒɡnɪzənt/',
        partOfSpeech: 'adjective',
        definition: 'Having knowledge or being aware of',
        example: 'She was cognizant of the risks involved.',
        synonyms: ['aware', 'conscious', 'informed'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Pedagogy',
        pronunciation: '/ˈpedəɡɒdʒi/',
        partOfSpeech: 'noun',
        definition: 'The method and practice of teaching',
        example: 'Modern pedagogy emphasizes student engagement.',
        synonyms: ['teaching', 'education', 'instruction'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Discourse',
        pronunciation: '/ˈdɪskɔːs/',
        partOfSpeech: 'noun',
        definition: 'Written or spoken communication',
        example: 'Academic discourse requires formal language.',
        synonyms: ['discussion', 'dialogue', 'conversation'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Conjecture',
        pronunciation: '/kənˈdʒektʃə/',
        partOfSpeech: 'noun',
        definition: 'An opinion formed without proof',
        example: 'His theory is based on conjecture.',
        synonyms: ['speculation', 'guess', 'hypothesis'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Delineate',
        pronunciation: '/dɪˈlɪnieɪt/',
        partOfSpeech: 'verb',
        definition: 'To describe or outline precisely',
        example: 'The report delineates the main issues.',
        synonyms: ['outline', 'describe', 'define'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Enumerate',
        pronunciation: '/ɪˈnjuːməreɪt/',
        partOfSpeech: 'verb',
        definition: 'To list or mention one by one',
        example: 'She enumerated the reasons for her decision.',
        synonyms: ['list', 'count', 'specify'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Implicit',
        pronunciation: '/ɪmˈplɪsɪt/',
        partOfSpeech: 'adjective',
        definition: 'Implied but not directly expressed',
        example: 'There was an implicit understanding.',
        synonyms: ['implied', 'unspoken', 'tacit'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Inference',
        pronunciation: '/ˈɪnfərəns/',
        partOfSpeech: 'noun',
        definition: 'A conclusion reached from evidence',
        example: 'The inference was based on the data.',
        synonyms: ['conclusion', 'deduction', 'reasoning'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Scrutinize',
        pronunciation: '/ˈskruːtɪnaɪz/',
        partOfSpeech: 'verb',
        definition: 'To examine something very carefully',
        example: 'The committee scrutinized the proposal.',
        synonyms: ['examine', 'inspect', 'analyze'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Premise',
        pronunciation: '/ˈpremɪs/',
        partOfSpeech: 'noun',
        definition: 'A statement assumed to be true',
        example: 'The argument is based on a false premise.',
        synonyms: ['assumption', 'proposition', 'hypothesis'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Substantive',
        pronunciation: '/ˈsʌbstəntɪv/',
        partOfSpeech: 'adjective',
        definition: 'Having real importance or value',
        example: 'We need substantive changes.',
        synonyms: ['meaningful', 'significant', 'important'],
        difficulty: 'Advanced',
      ),
    ],
  ),
  VocabCategory(
    name: 'Business Vocabulary',
    emoji: '💼',
    color: const Color(0xFF00B894),
    words: [
      VocabWord(
        word: 'Leverage',
        pronunciation: '/ˈlevərɪdʒ/',
        partOfSpeech: 'verb',
        definition: 'To use something to maximum advantage',
        example: 'We can leverage our connections.',
        synonyms: ['utilize', 'exploit', 'capitalize'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Synergy',
        pronunciation: '/ˈsɪnədʒi/',
        partOfSpeech: 'noun',
        definition: 'Combined effect greater than separate parts',
        example: 'The merger created real synergy.',
        synonyms: ['cooperation', 'collaboration', 'teamwork'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Scalable',
        pronunciation: '/ˈskeɪləbəl/',
        partOfSpeech: 'adjective',
        definition: 'Able to grow or be made larger',
        example: 'Is this business model scalable?',
        synonyms: ['expandable', 'flexible', 'adaptable'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Stakeholder',
        pronunciation: '/ˈsteɪkhəʊldə/',
        partOfSpeech: 'noun',
        definition: 'Someone with an interest in something',
        example: 'All stakeholders were consulted.',
        synonyms: ['investor', 'participant', 'shareholder'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Streamline',
        pronunciation: '/ˈstriːmlaɪn/',
        partOfSpeech: 'verb',
        definition: 'To make more efficient',
        example: 'We need to streamline our processes.',
        synonyms: ['simplify', 'optimize', 'improve'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Diversification',
        pronunciation: '/daɪˌvɜːsɪfɪˈkeɪʃən/',
        partOfSpeech: 'noun',
        definition: 'The process of expanding into different areas',
        example: 'Diversification reduces investment risk.',
        synonyms: ['expansion', 'variety', 'broadening'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Liquidate',
        pronunciation: '/ˈlɪkwɪdeɪt/',
        partOfSpeech: 'verb',
        definition: 'To convert assets into cash or close a business',
        example: 'The company was forced to liquidate.',
        synonyms: ['sell off', 'dissolve', 'wind up'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Acquisition',
        pronunciation: '/ˌækwɪˈzɪʃən/',
        partOfSpeech: 'noun',
        definition: 'The act of acquiring or buying something',
        example: 'The acquisition cost millions.',
        synonyms: ['purchase', 'takeover', 'buyout'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Amortization',
        pronunciation: '/əˌmɔːtaɪˈzeɪʃən/',
        partOfSpeech: 'noun',
        definition: 'Spreading payments over multiple periods',
        example: 'The loan amortization is 30 years.',
        synonyms: ['repayment', 'depreciation', 'allocation'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Volatility',
        pronunciation: '/ˌvɒləˈtɪləti/',
        partOfSpeech: 'noun',
        definition: 'Tendency to change rapidly and unpredictably',
        example: 'Market volatility increased this quarter.',
        synonyms: ['instability', 'fluctuation', 'unpredictability'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Benchmark',
        pronunciation: '/ˈbentʃmɑːk/',
        partOfSpeech: 'noun',
        definition: 'A standard for measuring or comparing',
        example: 'We use industry benchmarks for evaluation.',
        synonyms: ['standard', 'reference', 'criterion'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Paradigm',
        pronunciation: '/ˈpærədaɪm/',
        partOfSpeech: 'noun',
        definition: 'A framework or model for understanding',
        example: 'This represents a paradigm shift in business.',
        synonyms: ['model', 'framework', 'pattern'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Commoditization',
        pronunciation: '/kəˌmɒdɪtaɪˈzeɪʃən/',
        partOfSpeech: 'noun',
        definition: 'When products become indistinguishable',
        example: 'Commoditization drives prices down.',
        synonyms: ['standardization', 'homogenization'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Fiduciary',
        pronunciation: '/fɪˈdjuːʃəri/',
        partOfSpeech: 'adjective',
        definition: 'Involving trust, especially regarding money',
        example: 'Managers have fiduciary responsibilities.',
        synonyms: ['trustee', 'custodian', 'guardian'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Procurement',
        pronunciation: '/prəˈkjʊəmənt/',
        partOfSpeech: 'noun',
        definition: 'The process of obtaining goods or services',
        example: 'Procurement costs have increased.',
        synonyms: ['acquisition', 'purchasing', 'sourcing'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Depreciation',
        pronunciation: '/dɪˌpriːʃiˈeɪʃən/',
        partOfSpeech: 'noun',
        definition: 'A reduction in value over time',
        example: 'Asset depreciation affects taxes.',
        synonyms: ['devaluation', 'decrease', 'decline'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Equity',
        pronunciation: '/ˈekwɪti/',
        partOfSpeech: 'noun',
        definition: 'The value of shares in a company',
        example: 'They offered equity to investors.',
        synonyms: ['shares', 'ownership', 'stake'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Liability',
        pronunciation: '/ˌlaɪəˈbɪləti/',
        partOfSpeech: 'noun',
        definition: 'Something owed; a debt or obligation',
        example: 'The company has significant liabilities.',
        synonyms: ['debt', 'obligation', 'responsibility'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Monetize',
        pronunciation: '/ˈmʌnɪtaɪz/',
        partOfSpeech: 'verb',
        definition: 'To convert into money or profit',
        example: 'They monetize content through ads.',
        synonyms: ['commercialize', 'profit', 'capitalize'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Outsource',
        pronunciation: '/ˈaʊtsɔːs/',
        partOfSpeech: 'verb',
        definition: 'To contract work to external parties',
        example: 'We outsource IT support.',
        synonyms: ['subcontract', 'delegate', 'contract out'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Prospectus',
        pronunciation: '/prəˈspektəs/',
        partOfSpeech: 'noun',
        definition: 'A document describing a business offering',
        example: 'Review the prospectus before investing.',
        synonyms: ['brochure', 'document', 'proposal'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Consortium',
        pronunciation: '/kənˈsɔːtiəm/',
        partOfSpeech: 'noun',
        definition: 'A group of companies working together',
        example: 'A consortium bid for the contract.',
        synonyms: ['alliance', 'partnership', 'coalition'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Overhead',
        pronunciation: '/ˈəʊvəhed/',
        partOfSpeech: 'noun',
        definition: 'Ongoing business operating expenses',
        example: 'We need to reduce overhead costs.',
        synonyms: ['expenses', 'costs', 'operating costs'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Arbitrage',
        pronunciation: '/ˈɑːbɪtrɑːʒ/',
        partOfSpeech: 'noun',
        definition: 'Profiting from price differences',
        example: 'Currency arbitrage can be risky.',
        synonyms: ['trading', 'speculation', 'dealing'],
        difficulty: 'Advanced',
      ),
    ],
  ),
  VocabCategory(
    name: 'Emotional Expressions',
    emoji: '💭',
    color: const Color(0xFFFF6B6B),
    words: [
      VocabWord(
        word: 'Ecstatic',
        pronunciation: '/ɪkˈstætɪk/',
        partOfSpeech: 'adjective',
        definition: 'Extremely happy or excited',
        example: 'She was ecstatic about the news.',
        synonyms: ['overjoyed', 'thrilled', 'elated'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Apprehensive',
        pronunciation: '/ˌæprɪˈhensɪv/',
        partOfSpeech: 'adjective',
        definition: 'Anxious or fearful about the future',
        example: 'I feel apprehensive about the interview.',
        synonyms: ['worried', 'anxious', 'nervous'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Melancholy',
        pronunciation: '/ˈmelənkɒli/',
        partOfSpeech: 'adjective',
        definition: 'A deep sadness or depression',
        example: 'The song has a melancholy tone.',
        synonyms: ['sad', 'sorrowful', 'gloomy'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Exhilarated',
        pronunciation: '/ɪɡˈzɪləreɪtɪd/',
        partOfSpeech: 'adjective',
        definition: 'Feeling very happy and excited',
        example: 'I felt exhilarated after the race.',
        synonyms: ['thrilled', 'elated', 'euphoric'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Nostalgic',
        pronunciation: '/nɒˈstældʒɪk/',
        partOfSpeech: 'adjective',
        definition: 'Longing for the past',
        example: 'Old photos make me nostalgic.',
        synonyms: ['wistful', 'sentimental', 'longing'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Despondent',
        pronunciation: '/dɪˈspɒndənt/',
        partOfSpeech: 'adjective',
        definition: 'In low spirits from loss of hope',
        example: 'He felt despondent after the failure.',
        synonyms: ['dejected', 'disheartened', 'hopeless'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Euphoric',
        pronunciation: '/juːˈfɒrɪk/',
        partOfSpeech: 'adjective',
        definition: 'Intensely happy or confident',
        example: 'The victory made them euphoric.',
        synonyms: ['elated', 'overjoyed', 'ecstatic'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ambivalent',
        pronunciation: '/æmˈbɪvələnt/',
        partOfSpeech: 'adjective',
        definition: 'Having mixed feelings about something',
        example: 'I am ambivalent about the decision.',
        synonyms: ['uncertain', 'conflicted', 'undecided'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Indignant',
        pronunciation: '/ɪnˈdɪɡnənt/',
        partOfSpeech: 'adjective',
        definition: 'Feeling anger at unfair treatment',
        example: 'She was indignant at the accusation.',
        synonyms: ['outraged', 'offended', 'resentful'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Pensive',
        pronunciation: '/ˈpensɪv/',
        partOfSpeech: 'adjective',
        definition: 'Engaged in deep or serious thought',
        example: 'He sat in pensive silence.',
        synonyms: ['thoughtful', 'reflective', 'contemplative'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Wistful',
        pronunciation: '/ˈwɪstfʊl/',
        partOfSpeech: 'adjective',
        definition: 'Having a feeling of vague longing',
        example: 'She gave a wistful smile.',
        synonyms: ['yearning', 'longing', 'nostalgic'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Vindictive',
        pronunciation: '/vɪnˈdɪktɪv/',
        partOfSpeech: 'adjective',
        definition: 'Having a strong desire for revenge',
        example: 'His vindictive behavior was hurtful.',
        synonyms: ['vengeful', 'spiteful', 'resentful'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Magnanimous',
        pronunciation: '/mæɡˈnænɪməs/',
        partOfSpeech: 'adjective',
        definition: 'Very generous or forgiving',
        example: 'She was magnanimous in victory.',
        synonyms: ['generous', 'noble', 'gracious'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Reticent',
        pronunciation: '/ˈretɪsənt/',
        partOfSpeech: 'adjective',
        definition: 'Not revealing thoughts or feelings readily',
        example: 'He was reticent about his past.',
        synonyms: ['reserved', 'quiet', 'uncommunicative'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Ebullient',
        pronunciation: '/ɪˈbʌliənt/',
        partOfSpeech: 'adjective',
        definition: 'Cheerful and full of energy',
        example: 'Her ebullient personality is infectious.',
        synonyms: ['enthusiastic', 'exuberant', 'buoyant'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Contemptuous',
        pronunciation: '/kənˈtemptʃuəs/',
        partOfSpeech: 'adjective',
        definition: 'Showing strong disrespect',
        example: 'He gave a contemptuous laugh.',
        synonyms: ['scornful', 'disdainful', 'dismissive'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Forlorn',
        pronunciation: '/fəˈlɔːn/',
        partOfSpeech: 'adjective',
        definition: 'Sad and lonely',
        example: 'The forlorn puppy needed a home.',
        synonyms: ['sad', 'lonely', 'desolate'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Livid',
        pronunciation: '/ˈlɪvɪd/',
        partOfSpeech: 'adjective',
        definition: 'Extremely angry',
        example: 'She was livid when she found out.',
        synonyms: ['furious', 'enraged', 'infuriated'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Perturbed',
        pronunciation: '/pəˈtɜːbd/',
        partOfSpeech: 'adjective',
        definition: 'Anxious or unsettled',
        example: 'He seemed perturbed by the news.',
        synonyms: ['worried', 'troubled', 'disturbed'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Disgruntled',
        pronunciation: '/dɪsˈɡrʌntld/',
        partOfSpeech: 'adjective',
        definition: 'Angry or dissatisfied',
        example: 'The disgruntled employees complained.',
        synonyms: ['dissatisfied', 'annoyed', 'unhappy'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Elated',
        pronunciation: '/ɪˈleɪtɪd/',
        partOfSpeech: 'adjective',
        definition: 'Extremely happy and excited',
        example: 'She was elated by the promotion.',
        synonyms: ['overjoyed', 'thrilled', 'delighted'],
        difficulty: 'Intermediate',
      ),
      VocabWord(
        word: 'Morose',
        pronunciation: '/məˈrəʊs/',
        partOfSpeech: 'adjective',
        definition: 'Sullen and ill-tempered',
        example: 'He has been morose all week.',
        synonyms: ['gloomy', 'sulky', 'sullen'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Sanguine',
        pronunciation: '/ˈsæŋɡwɪn/',
        partOfSpeech: 'adjective',
        definition: 'Optimistic and cheerful',
        example: 'She remains sanguine about the future.',
        synonyms: ['optimistic', 'hopeful', 'positive'],
        difficulty: 'Advanced',
      ),
      VocabWord(
        word: 'Apathetic',
        pronunciation: '/ˌæpəˈθetɪk/',
        partOfSpeech: 'adjective',
        definition: 'Showing no interest or enthusiasm',
        example: 'Voters have become apathetic.',
        synonyms: ['indifferent', 'uninterested', 'unconcerned'],
        difficulty: 'Intermediate',
      ),
    ],
  ),
];

// Game modes
enum VocabGameMode { flashcard, quiz, matching, spelling }

class VocabularyScreenNew extends ConsumerStatefulWidget {
  const VocabularyScreenNew({super.key});

  @override
  ConsumerState<VocabularyScreenNew> createState() =>
      _VocabularyScreenNewState();
}

class _VocabularyScreenNewState extends ConsumerState<VocabularyScreenNew>
    with TickerProviderStateMixin {
  VocabCategory? _selectedCategory;
  List<VocabWord> _shuffledWords = []; // Randomized words for this session
  VocabGameMode _gameMode = VocabGameMode.flashcard;
  int _currentWordIndex = 0;
  bool _showDefinition = false;

  // Gamification
  int _xpEarned = 0;
  int _wordsLearned = 0;
  int _correctAnswers = 0;
  int _totalQuestions = 0; // Track total questions for quiz analysis
  int _streak = 0;
  int _bestStreak = 0;

  // Quiz mode
  List<String> _quizOptions = [];
  String? _selectedAnswer;
  bool? _isCorrect;

  // Matching mode
  List<VocabWord> _matchingWords = [];
  List<String> _matchingDefinitions = [];
  int? _selectedWordIndex;
  int? _selectedDefIndex;
  List<int> _matchedWords = [];
  List<int> _matchedDefs = [];

  // Spelling mode
  final TextEditingController _spellingController = TextEditingController();
  bool _spellingChecked = false;
  bool _spellingCorrect = false;

  late AnimationController _cardController;
  late AnimationController _streakController;

  @override
  void initState() {
    super.initState();
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _streakController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _cardController.dispose();
    _streakController.dispose();
    _spellingController.dispose();
    super.dispose();
  }

  void _selectCategory(VocabCategory category) {
    // Shuffle words for this session - gives different 5 words every time
    final shuffledWordsList = List<VocabWord>.from(category.words)..shuffle();
    // Take 5 random words for this session
    final sessionWords = shuffledWordsList.take(5).toList();

    setState(() {
      _selectedCategory = category;
      _shuffledWords = sessionWords;
      _currentWordIndex = 0;
      _showDefinition = false;
      _xpEarned = 0;
      _wordsLearned = 0;
      _correctAnswers = 0;
      _totalQuestions = 0;
      _streak = 0;
      _bestStreak = 0;
    });
    _setupGameMode();
  }

  void _selectGameMode(VocabGameMode mode) {
    // Re-shuffle words when changing game mode for variety
    if (_selectedCategory != null) {
      final shuffledWordsList = List<VocabWord>.from(_selectedCategory!.words)
        ..shuffle();
      final sessionWords = shuffledWordsList.take(5).toList();
      setState(() {
        _shuffledWords = sessionWords;
      });
    }
    setState(() {
      _gameMode = mode;
      _currentWordIndex = 0;
      _correctAnswers = 0;
      _totalQuestions = 0;
    });
    _setupGameMode();
  }

  void _setupGameMode() {
    switch (_gameMode) {
      case VocabGameMode.quiz:
        _generateQuizOptions();
        break;
      case VocabGameMode.matching:
        _setupMatchingGame();
        break;
      case VocabGameMode.spelling:
        _spellingController.clear();
        _spellingChecked = false;
        break;
      default:
        break;
    }
  }

  void _generateQuizOptions() {
    final currentWord = _shuffledWords[_currentWordIndex];
    final allDefinitions = _shuffledWords.map((w) => w.definition).toList();
    allDefinitions.shuffle();

    _quizOptions = allDefinitions.take(4).toList();
    if (!_quizOptions.contains(currentWord.definition)) {
      _quizOptions[Random().nextInt(4)] = currentWord.definition;
    }
    _selectedAnswer = null;
    _isCorrect = null;
  }

  void _setupMatchingGame() {
    _matchingWords = List.from(_shuffledWords)..shuffle();
    _matchingWords = _matchingWords.take(5).toList();
    _matchingDefinitions = _matchingWords.map((w) => w.definition).toList()
      ..shuffle();
    _selectedWordIndex = null;
    _selectedDefIndex = null;
    _matchedWords = [];
    _matchedDefs = [];
  }

  void _handleFlashcardGotIt() {
    final currentWord = _shuffledWords[_currentWordIndex];
    setState(() {
      _wordsLearned++;
      _streak++;
      _bestStreak = max(_streak, _bestStreak);
      _xpEarned += 10 + (_streak * 2);
      _showDefinition = false;
    });
    _streakController.forward(from: 0);

    // Save word to persistent storage
    _saveLearnedWord(currentWord);

    _nextWord();
  }

  Future<void> _saveLearnedWord(VocabWord word) async {
    try {
      final service = ref.read(userJourneyServiceProvider);
      await service.addLearnedWord(
        word: word.word,
        definition: word.definition,
        example: word.example,
        partOfSpeech: word.partOfSpeech,
      );
    } catch (e) {
      // Silently fail - don't interrupt user experience
      debugPrint('Failed to save learned word: $e');
    }
  }

  void _handleFlashcardStudyAgain() {
    setState(() {
      _streak = 0;
      _showDefinition = false;
    });
    _nextWord();
  }

  void _handleQuizAnswer(String answer) {
    final currentWord = _shuffledWords[_currentWordIndex];
    final correct = answer == currentWord.definition;

    // Track total questions answered
    setState(() {
      _totalQuestions++;
      _selectedAnswer = answer;
      _isCorrect = correct;
      if (correct) {
        _correctAnswers++;
        _streak++;
        _bestStreak = max(_streak, _bestStreak);
        _xpEarned += 15 + (_streak * 3);
        _wordsLearned++;
        // Save learned word
        _saveLearnedWord(currentWord);
      } else {
        _streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) _nextWord();
    });
  }

  void _handleMatchSelection(bool isWord, int index) {
    if (isWord && _matchedWords.contains(index)) return;
    if (!isWord && _matchedDefs.contains(index)) return;

    setState(() {
      if (isWord) {
        _selectedWordIndex = index;
      } else {
        _selectedDefIndex = index;
      }
    });

    // Check for match
    if (_selectedWordIndex != null && _selectedDefIndex != null) {
      final word = _matchingWords[_selectedWordIndex!];
      final def = _matchingDefinitions[_selectedDefIndex!];

      if (word.definition == def) {
        // Match!
        setState(() {
          _matchedWords.add(_selectedWordIndex!);
          _matchedDefs.add(_selectedDefIndex!);
          _correctAnswers++;
          _streak++;
          _bestStreak = max(_streak, _bestStreak);
          _xpEarned += 20 + (_streak * 5);
          _wordsLearned++;
        });
        _streakController.forward(from: 0);
        // Save learned word
        _saveLearnedWord(word);
      } else {
        _streak = 0;
      }

      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() {
            _selectedWordIndex = null;
            _selectedDefIndex = null;
          });
        }
      });

      // Check completion
      if (_matchedWords.length == _matchingWords.length) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showCompletionDialog();
        });
      }
    }
  }

  void _checkSpelling() {
    final currentWord = _shuffledWords[_currentWordIndex];
    final userInput = _spellingController.text.trim().toLowerCase();
    final correct = userInput == currentWord.word.toLowerCase();

    setState(() {
      _spellingChecked = true;
      _spellingCorrect = correct;
      _totalQuestions++; // Track for quiz analysis
      if (correct) {
        _correctAnswers++;
        _streak++;
        _bestStreak = max(_streak, _bestStreak);
        _xpEarned += 25 + (_streak * 5);
        _wordsLearned++;
        // Save learned word
        _saveLearnedWord(currentWord);
      } else {
        _streak = 0;
      }
    });

    if (correct) _streakController.forward(from: 0);
  }

  void _nextSpellingWord() {
    setState(() {
      _spellingController.clear();
      _spellingChecked = false;
      _spellingCorrect = false;
    });
    _nextWord();
  }

  void _nextWord() {
    if (_currentWordIndex < _shuffledWords.length - 1) {
      setState(() {
        _currentWordIndex++;
        _showDefinition = false;
      });
      _cardController.forward(from: 0);
      _setupGameMode();
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final totalWords = _gameMode == VocabGameMode.matching
        ? _matchingWords.length
        : _shuffledWords.length;
    final accuracy = totalWords > 0
        ? (_wordsLearned / totalWords * 100).round()
        : 0;

    // Calculate incorrect answers for quiz analysis
    final incorrectAnswers = _totalQuestions - _correctAnswers;
    final isQuizMode =
        _gameMode == VocabGameMode.quiz || _gameMode == VocabGameMode.spelling;

    // Determine next mode
    final currentModeIndex = VocabGameMode.values.indexOf(_gameMode);
    final hasNextMode = currentModeIndex < VocabGameMode.values.length - 1;
    final nextMode = hasNextMode
        ? VocabGameMode.values[currentModeIndex + 1]
        : null;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _selectedCategory!.color,
                        _selectedCategory!.color.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _selectedCategory!.emoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                const SizedBox(height: 24),
                Text(
                  accuracy >= 80
                      ? 'Outstanding! 🌟'
                      : accuracy >= 60
                      ? 'Great Work! 🎉'
                      : 'Keep Learning! 💪',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory!.name,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CompletionStat(
                      icon: Icons.check_circle_outline_rounded,
                      value: '$_wordsLearned',
                      label: 'Learned',
                      color: AppColors.success,
                    ),
                    _CompletionStat(
                      icon: Icons.local_fire_department_rounded,
                      value: '$_bestStreak',
                      label: 'Best Streak',
                      color: AppColors.error,
                    ),
                    _CompletionStat(
                      icon: Icons.percent_rounded,
                      value: '$accuracy%',
                      label: 'Accuracy',
                      color: AppColors.primary,
                    ),
                  ],
                ),
                // Quiz Analysis Section - shows correct/incorrect count
                if (isQuizMode && _totalQuestions > 0) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Quiz Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    color: AppColors.success,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_correctAnswers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.success,
                                  ),
                                ),
                                Text(
                                  'Correct',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.divider,
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.error.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$incorrectAnswers',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.error,
                                  ),
                                ),
                                Text(
                                  'Incorrect',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: isDark
                                  ? AppColors.dividerDark
                                  : AppColors.divider,
                            ),
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.quiz_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_totalQuestions',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentYellow.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.accentYellow,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '+$_xpEarned XP',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentYellow,
                            ),
                          ),
                        ],
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 300.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 28),
                // Highlighted "Next Mode" button if there's a next mode
                if (hasNextMode && nextMode != null) ...[
                  Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _selectGameMode(nextMode);
                          },
                          icon: Icon(_getModeIcon(nextMode)),
                          label: Text(
                            'Continue to ${_getModeName(nextMode)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 400.ms)
                      .shimmer(
                        duration: 1500.ms,
                        color: Colors.white.withOpacity(0.3),
                      ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _selectedCategory = null;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Categories'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: hasNextMode
                          ? OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.pop();
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Done'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                context.pop();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                              ),
                              child: const Text('Complete! 🎉'),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getModeName(VocabGameMode mode) {
    switch (mode) {
      case VocabGameMode.flashcard:
        return 'Flashcards';
      case VocabGameMode.quiz:
        return 'Quiz';
      case VocabGameMode.matching:
        return 'Matching';
      case VocabGameMode.spelling:
        return 'Spelling';
    }
  }

  IconData _getModeIcon(VocabGameMode mode) {
    switch (mode) {
      case VocabGameMode.flashcard:
        return Icons.style_rounded;
      case VocabGameMode.quiz:
        return Icons.quiz_rounded;
      case VocabGameMode.matching:
        return Icons.compare_arrows_rounded;
      case VocabGameMode.spelling:
        return Icons.spellcheck_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          onPressed: () {
            if (_selectedCategory != null) {
              setState(() => _selectedCategory = null);
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          _selectedCategory?.name ?? 'Vocabulary Builder',
          style: TextStyle(
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_selectedCategory != null) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.error,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_streak',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentYellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.accentYellow,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$_xpEarned',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: _selectedCategory == null
            ? _buildCategorySelection(isDark)
            : _buildGameView(isDark),
      ),
    );
  }

  Widget _buildCategorySelection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Build Your Vocabulary 📖',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose a category to start learning',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _vocabCategories.length,
            itemBuilder: (context, index) {
              final category = _vocabCategories[index];
              return _VocabCategoryCard(
                    category: category,
                    onTap: () => _selectCategory(category),
                  )
                  .animate(delay: Duration(milliseconds: 80 * index))
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGameView(bool isDark) {
    return Column(
      children: [
        // Game mode selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: VocabGameMode.values.map((mode) {
                final isSelected = _gameMode == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_getModeName(mode)),
                    selected: isSelected,
                    onSelected: (_) => _selectGameMode(mode),
                    selectedColor: _selectedCategory!.color,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: FontWeight.w600,
                    ),
                    avatar: Icon(
                      _getModeIcon(mode),
                      size: 18,
                      color: isSelected
                          ? Colors.white
                          : _selectedCategory!.color,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Progress
        if (_gameMode != VocabGameMode.matching)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${_currentWordIndex + 1}/${_shuffledWords.length}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_currentWordIndex + 1) / _shuffledWords.length,
                      backgroundColor: isDark
                          ? AppColors.dividerDark
                          : AppColors.divider,
                      valueColor: AlwaysStoppedAnimation(
                        _selectedCategory!.color,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 16),

        // Game content
        Expanded(child: _buildGameContent(isDark)),
      ],
    );
  }

  Widget _buildGameContent(bool isDark) {
    switch (_gameMode) {
      case VocabGameMode.flashcard:
        return _buildFlashcardMode(isDark);
      case VocabGameMode.quiz:
        return _buildQuizMode(isDark);
      case VocabGameMode.matching:
        return _buildMatchingMode(isDark);
      case VocabGameMode.spelling:
        return _buildSpellingMode(isDark);
    }
  }

  Widget _buildFlashcardMode(bool isDark) {
    final currentWord = _shuffledWords[_currentWordIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _showDefinition = !_showDefinition),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _selectedCategory!.color.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Difficulty badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getDifficultyColor(
                          currentWord.difficulty,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        currentWord.difficulty,
                        style: TextStyle(
                          color: _getDifficultyColor(currentWord.difficulty),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),

                    // Word
                    Text(
                      currentWord.word,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Pronunciation
                    Text(
                      currentWord.pronunciation,
                      style: TextStyle(
                        fontSize: 18,
                        color: _selectedCategory!.color,
                        fontFamily: 'monospace',
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Part of speech
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedCategory!.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        currentWord.partOfSpeech,
                        style: TextStyle(
                          color: _selectedCategory!.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Definition (revealed)
                    AnimatedCrossFade(
                      firstChild: Column(
                        children: [
                          Icon(
                            Icons.touch_app_rounded,
                            color: AppColors.textHint,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to reveal definition',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      secondChild: Column(
                        children: [
                          Text(
                            currentWord.definition,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '"${currentWord.example}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            children: currentWord.synonyms
                                .map(
                                  (s) => Chip(
                                    label: Text(
                                      s,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    backgroundColor: _selectedCategory!.color
                                        .withOpacity(0.1),
                                    labelStyle: TextStyle(
                                      color: _selectedCategory!.color,
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                      crossFadeState: _showDefinition
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 300),
                    ),

                    const Spacer(),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          const SizedBox(height: 20),

          // Buttons
          if (_showDefinition)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _handleFlashcardStudyAgain,
                    icon: const Icon(Icons.replay_rounded),
                    label: const Text('Study Again'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleFlashcardGotIt,
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Got It!'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _selectedCategory!.color,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildQuizMode(bool isDark) {
    final currentWord = _shuffledWords[_currentWordIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Word to guess
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _selectedCategory!.color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'What does this word mean?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentWord.word,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: _selectedCategory!.color,
                  ),
                ),
                Text(
                  currentWord.pronunciation,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 24),

          // Options
          Expanded(
            child: ListView.builder(
              itemCount: _quizOptions.length,
              itemBuilder: (context, index) {
                final option = _quizOptions[index];
                final isSelected = _selectedAnswer == option;
                final isCorrectAnswer = option == currentWord.definition;

                Color? backgroundColor;
                Color? borderColor;

                if (_selectedAnswer != null) {
                  if (isCorrectAnswer) {
                    backgroundColor = AppColors.success.withOpacity(0.15);
                    borderColor = AppColors.success;
                  } else if (isSelected && !_isCorrect!) {
                    backgroundColor = AppColors.error.withOpacity(0.15);
                    borderColor = AppColors.error;
                  }
                }

                return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: _selectedAnswer == null
                            ? () => _handleQuizAnswer(option)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                backgroundColor ??
                                (isDark ? AppColors.cardDark : Colors.white),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  borderColor ??
                                  (isDark
                                      ? AppColors.dividerDark
                                      : AppColors.divider),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: _selectedCategory!.color.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + index),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _selectedCategory!.color,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (_selectedAnswer != null && isCorrectAnswer)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.success,
                                ),
                              if (isSelected && !(_isCorrect ?? true))
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: AppColors.error,
                                ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .animate(delay: Duration(milliseconds: 100 * index))
                    .fadeIn(duration: 300.ms)
                    .slideX(begin: 0.05);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchingMode(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Match words with their definitions',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Text(
            '${_matchedWords.length}/${_matchingWords.length} matched',
            style: TextStyle(
              color: _selectedCategory!.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                // Words column
                Expanded(
                  child: ListView.builder(
                    itemCount: _matchingWords.length,
                    itemBuilder: (context, index) {
                      final word = _matchingWords[index];
                      final isMatched = _matchedWords.contains(index);
                      final isSelected = _selectedWordIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: isMatched
                              ? null
                              : () => _handleMatchSelection(true, index),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? AppColors.success.withOpacity(0.15)
                                  : (isSelected
                                        ? _selectedCategory!.color.withOpacity(
                                            0.15,
                                          )
                                        : (isDark
                                              ? AppColors.cardDark
                                              : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? AppColors.success
                                    : (isSelected
                                          ? _selectedCategory!.color
                                          : Colors.transparent),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              word.word,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isMatched
                                    ? AppColors.success
                                    : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 12),

                // Definitions column
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: _matchingDefinitions.length,
                    itemBuilder: (context, index) {
                      final def = _matchingDefinitions[index];
                      final isMatched = _matchedDefs.contains(index);
                      final isSelected = _selectedDefIndex == index;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: GestureDetector(
                          onTap: isMatched
                              ? null
                              : () => _handleMatchSelection(false, index),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isMatched
                                  ? AppColors.success.withOpacity(0.15)
                                  : (isSelected
                                        ? _selectedCategory!.color.withOpacity(
                                            0.15,
                                          )
                                        : (isDark
                                              ? AppColors.cardDark
                                              : Colors.white)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isMatched
                                    ? AppColors.success
                                    : (isSelected
                                          ? _selectedCategory!.color
                                          : Colors.transparent),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              def,
                              style: TextStyle(
                                fontSize: 13,
                                color: isMatched
                                    ? AppColors.success
                                    : (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpellingMode(bool isDark) {
    final currentWord = _shuffledWords[_currentWordIndex];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Definition card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _selectedCategory!.color.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.edit_rounded,
                  color: _selectedCategory!.color,
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  'Spell the word that means:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  currentWord.definition,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Hint: ${currentWord.partOfSpeech} • ${currentWord.word.length} letters',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 32),

          // Text input
          TextField(
            controller: _spellingController,
            enabled: !_spellingChecked,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: _spellingChecked
                  ? (_spellingCorrect ? AppColors.success : AppColors.error)
                  : null,
            ),
            decoration: InputDecoration(
              hintText: 'Type your answer...',
              hintStyle: TextStyle(
                color: AppColors.textHint,
                fontSize: 20,
                letterSpacing: 0,
              ),
              filled: true,
              fillColor: isDark ? AppColors.cardDark : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedCategory!.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: _selectedCategory!.color,
                  width: 2,
                ),
              ),
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => _checkSpelling(),
          ),

          const SizedBox(height: 24),

          // Result
          if (_spellingChecked)
            Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _spellingCorrect
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _spellingCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _spellingCorrect
                            ? AppColors.success
                            : AppColors.error,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _spellingCorrect ? 'Correct!' : 'The answer is:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _spellingCorrect
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      if (!_spellingCorrect) ...[
                        const SizedBox(height: 4),
                        Text(
                          currentWord.word,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9)),

          const Spacer(),

          // Buttons
          if (!_spellingChecked)
            ElevatedButton(
              onPressed: _checkSpelling,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory!.color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Check'),
            )
          else
            ElevatedButton(
              onPressed: _nextSpellingWord,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedCategory!.color,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: const Text('Next Word'),
            ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Beginner':
        return AppColors.success;
      case 'Intermediate':
        return AppColors.accentYellow;
      case 'Advanced':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }
}

class _VocabCategoryCard extends StatelessWidget {
  final VocabCategory category;
  final VoidCallback onTap;

  const _VocabCategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: category.color.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.words.length} words to learn',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress bar placeholder
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.3, // Placeholder
                      backgroundColor: category.color.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(category.color),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: category.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: category.color,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _CompletionStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
