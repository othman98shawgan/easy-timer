import 'package:flutter/material.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:numberpicker/numberpicker.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _duration = 0;
  final CountDownController _controller = CountDownController();
  List<int> _currentTimeValue = [0, 0, 0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            // onPressed: () => pickTimer(),
            onPressed: (() => showSetTimerDialog(context)),
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPress: () {
          _controller.restart(duration: _duration);
          _controller.pause();
        },
        onTap: (() {
          if (_controller.isResumed) {
            _controller.pause();
          } else {
            _controller.resume();
          }
        }),
        child: Center(
          child: CircularCountDownTimer(
            autoStart: false,
            duration: _duration,
            initialDuration: 0,
            controller: _controller,
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.8,
            ringColor: Colors.cyan.shade500,
            fillColor: Colors.cyan.shade800,
            ringGradient: null,            
            backgroundColor: Colors.black54,
            // backgroundGradient: const LinearGradient(
            //     begin: Alignment.centerLeft,
            //     end: Alignment.centerRight,
            //     colors: [Colors.purple, Colors.blue]),
            strokeWidth: 20.0,
            strokeCap: StrokeCap.square,
            textStyle: const TextStyle(
              fontSize: 64.0,
              color: Colors.white,
              fontWeight: FontWeight.w300,
            ),
            timeFormatterFunction: (defaultFormatterFunction, duration) {
              return _timerFormat(duration);
            },
            isReverse: true,
            isReverseAnimation: true,
            isTimerTextShown: true,
            onComplete: () {
              // Here, do whatever you want
              debugPrint('Countdown Ended');
            },
            onChange: (String timeStamp) {
              if (!_controller.isStarted) {
                _controller.start();
                _controller.resume();
                _controller.pause();
              }
            },
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 30,
          ),
          _button(
              title: "Start",
              onPressed: () {
                _controller.resume();
              }),
          const SizedBox(
            width: 10,
          ),
          _button(
            title: "Stop",
            onPressed: () => _controller.pause(),
          ),
          const SizedBox(
            width: 10,
          ),
          _button(
              title: "Reset",
              onPressed: () {
                _controller.restart(duration: _duration);
                _controller.pause();
              }),
        ],
      ),
    );
  }

  _timerFormat(Duration duration) {
    if (duration.inHours != 0) {
      return '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    } else {
      return '${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
    }
  }

  Widget _button({required String title, VoidCallback? onPressed}) {
    return Expanded(
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.black54),
        ),
        onPressed: onPressed,
        child: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget setTimer(StateSetter SBsetState, int index, int min, int max) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberPicker(
            value: _currentTimeValue[index],
            zeroPad: true,
            textStyle: const TextStyle(fontSize: 18, color: Color.fromARGB(200, 189, 189, 189)),
            selectedTextStyle: const TextStyle(fontSize: 28),
            minValue: min,
            maxValue: max,
            infiniteLoop: true,
            onChanged: (value) {
              setState(() => _currentTimeValue[index] = value); // to change on widget level state
              SBsetState(() => _currentTimeValue[index] = value); //* to change on dialog state
            }),
      ],
    );
  }

  showSetTimerDialog(BuildContext context) {
    _currentTimeValue = [0, 0, 0];
    var confirmMethod = (() {
      setState(() {
        _duration =
            _currentTimeValue[0] + _currentTimeValue[1] * 60 + _currentTimeValue[2] * 60 * 60;
        _controller.restart(duration: _duration);
        _controller.pause();
      });
      Navigator.pop(context);
    });

    AlertDialog alert = AlertDialog(
      title: const Text("Set Timer"),
      contentPadding: const EdgeInsets.only(top: 32),
      actions: [
        ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        TextButton(
          onPressed: confirmMethod,
          child: const Text('Confirm'),
        ),
      ],
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  setTimer(setState, 2, 0, 99),
                  setTimer(setState, 1, 0, 59),
                  setTimer(setState, 0, 0, 59),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                '${_currentTimeValue[2].toString().padLeft(2, '0')} : ${_currentTimeValue[1].toString().padLeft(2, '0')} : ${_currentTimeValue[0].toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 36),
              ),
            ],
          );
        },
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
