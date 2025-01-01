// import 'package:eureka_final_version/frontend/models/constant/CalendarEvent.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ModernCalendarView extends StatefulWidget {
//   const ModernCalendarView({Key? key}) : super(key: key);

//   @override
//   State<ModernCalendarView> createState() => _ModernCalendarViewState();
// }

// class _ModernCalendarViewState extends State<ModernCalendarView>
//     with SingleTickerProviderStateMixin {
//   late DateTime _selectedDate;
//   late DateTime _focusedMonth;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;

//   // Dummy events data
//   // final Map<DateTime, List<CalendarEvent>> _events = {
//   //   DateTime(2024, 12, 16): [
//   //     CalendarEvent(
//   //       title: 'Team Meeting',
//   //       time: '10:00 AM',
//   //       color: Colors.blue,
//   //       icon: Icons.groups,
//   //     ),
//   //     CalendarEvent(
//   //       title: 'Project Review',
//   //       time: '2:30 PM',
//   //       color: Colors.orange,
//   //       icon: Icons.assessment,
//   //     ),
//   //   ],
//   //   DateTime(2024, 12, 18): [
//   //     CalendarEvent(
//   //       title: 'Client Presentation',
//   //       time: '11:00 AM',
//   //       color: Colors.purple,
//   //       icon: Icons.present_to_all,
//   //     ),
//   //   ],
//   // };

//   @override
//   void initState() {
//     super.initState();
//     _selectedDate = DateTime.now();
//     _focusedMonth = DateTime.now();

//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }

//   void _onDaySelected(DateTime day) {
//     setState(() {
//       _selectedDate = day;
//       _animationController.reset();
//       _animationController.forward();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildMonthSelector(),
//           const SizedBox(height: 20),
//           _buildCalendarGrid(),
//           const SizedBox(height: 20),
//           _buildEventsList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMonthSelector() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           DateFormat('MMMM yyyy').format(_focusedMonth),
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         Row(
//           children: [
//             IconButton(
//               icon: const Icon(Icons.chevron_left, color: Colors.white),
//               onPressed: () {
//                 setState(() {
//                   _focusedMonth = DateTime(
//                     _focusedMonth.year,
//                     _focusedMonth.month - 1,
//                   );
//                 });
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.chevron_right, color: Colors.white),
//               onPressed: () {
//                 setState(() {
//                   _focusedMonth = DateTime(
//                     _focusedMonth.year,
//                     _focusedMonth.month + 1,
//                   );
//                 });
//               },
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildCalendarGrid() {
//     final daysInMonth = DateTime(
//       _focusedMonth.year,
//       _focusedMonth.month + 1,
//       0,
//     ).day;

//     final firstDayOfMonth =
//         DateTime(_focusedMonth.year, _focusedMonth.month, 1);
//     final firstWeekday = firstDayOfMonth.weekday;

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.black.withOpacity(0.2),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
//                 .map((day) => Text(
//                       day,
//                       style: const TextStyle(
//                         color: Colors.grey,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ))
//                 .toList(),
//           ),
//           const SizedBox(height: 16),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 7,
//               mainAxisSpacing: 8,
//               crossAxisSpacing: 8,
//             ),
//             itemCount: 42, // 6 weeks * 7 days
//             itemBuilder: (context, index) {
//               final dayNumber = index - firstWeekday + 2;
//               if (dayNumber < 1 || dayNumber > daysInMonth) {
//                 return const SizedBox.shrink();
//               }

//               final date =
//                   DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
//               final isSelected = date.year == _selectedDate.year &&
//                   date.month == _selectedDate.month &&
//                   date.day == _selectedDate.day;
//               final hasEvents = _events[date]?.isNotEmpty ?? false;

//               return GestureDetector(
//                 onTap: () => _onDaySelected(date),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: isSelected
//                         ? Theme.of(context).primaryColor
//                         : Colors.transparent,
//                     borderRadius: BorderRadius.circular(10),
//                     border: hasEvents
//                         ? Border.all(color: Theme.of(context).primaryColor)
//                         : null,
//                   ),
//                   child: Center(
//                     child: Text(
//                       dayNumber.toString(),
//                       style: TextStyle(
//                         color: isSelected ? Colors.white : Colors.white70,
//                         fontWeight:
//                             isSelected ? FontWeight.bold : FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEventsList() {
//     final eventsForDay = _events[_selectedDate] ?? [];

//     return FadeTransition(
//       opacity: _fadeAnimation,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Events for ${DateFormat('MMMM d').format(_selectedDate)}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 12),
//           if (eventsForDay.isEmpty)
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.black.withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: const Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.event_busy, color: Colors.grey),
//                   SizedBox(width: 8),
//                   Text(
//                     'No events for this day',
//                     style: TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             )
//           else
//             ...eventsForDay.map((event) => _buildEventCard(event)),
//         ],
//       ),
//     );
//   }

//   Widget _buildEventCard(CalendarEvent event) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: event.color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(15),
//         border: Border.all(
//           color: event.color.withOpacity(0.3),
//           width: 1,
//         ),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: event.color.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(
//               event.icon,
//               color: event.color,
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   event.title,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   event.time,
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.7),
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
