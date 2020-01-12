import 'dart:async';

import 'package:flutter_clock_helper/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:intl/intl.dart';
import 'package:vector_math/vector_math_64.dart' show radians;

import 'container_hand.dart';
import 'drawn_hand.dart';
import 'dial.dart';

/// Total distance traveled by a second or a minute hand, each second or minute,
/// respectively.
final radiansPerTick = radians(360 / 60);

/// Total distance traveled by an hour hand, each hour, in radians.
final radiansPerHour = radians(360 / 12);

/// A basic analog clock.
///
/// You can do better than this!
class AnalogClock extends StatefulWidget {
  const AnalogClock(this.model);

  final ClockModel model;

  @override
  _AnalogClockState createState() => _AnalogClockState();
}

class _AnalogClockState extends State<AnalogClock> {
  var _now = DateTime.now();
  var _temperature = '';
  Timer _timer;
  final time = DateFormat.Hms().format(DateTime.now());
  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    // Set the initial values.
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(AnalogClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    super.dispose();
  }

  void _updateModel() {
    setState(() {
      _temperature = widget.model.temperatureString;
    });
  }

  void _updateTime() {
    setState(() {
      _now = DateTime.now();
      // Update once per second. Make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _now.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Semantics.fromProperties(
      properties: SemanticsProperties(
        label: 'Analog clock with time $time',
        value: time,
      ),
      child: Stack(
        children: [
          background(),
          myClock(),
        ],
      ),
    );
  }

  Widget background() {
    return Row(
      children: <Widget>[
        Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            color: Color(0xFF4285F4),
          ),
        ),
        Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            color: Color(0xFFDB4437),
          ),
        ),
        Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            color: Color(0xFFF4B400),
          ),
        ),
        Flexible(
          child: Container(
            width: MediaQuery.of(context).size.width / 4,
            color: Color(0xFF0F9D58),
          ),
        ),
      ],
    );
  }

  Widget weather() {
    return Card(
      color: Colors.black,
      elevation: 8.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _temperature,
          style: TextStyle(
            fontSize: 22.0,
            color: Color(0xFFF4B400),
          ),
        ),
      ),
    );
  }

  Widget myClock() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black,
      ),
      child: Stack(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ),
          ContainerHand(
            color: Colors.transparent,
            size: 0.5,
            angleRadians: _now.hour * radiansPerHour +
                (_now.minute / 60) * radiansPerHour,
            child: Transform.translate(
              offset: Offset(0.0, -60.0),
              child: Container(
                width: 16,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
              ),
            ),
          ),
          DrawnHand(
            color: Colors.white,
            thickness: 5,
            size: 0.7,
            angleRadians: _now.minute * radiansPerTick,
          ),
          DrawnHand(
            color: Colors.red,
            thickness: 4,
            size: 0.9,
            angleRadians: _now.second * radiansPerTick,
          ),
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey,
              ),
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: const EdgeInsets.all(10.0),
            child: new CustomPaint(
              painter: new Dial(),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: weather(),
            ),
          ),
        ],
      ),
    );
  }
}
