class BookingData {
  final String month;
  final int year;
  final int bookings;
  final int yearlyTotal;
  final List<DailyBooking>? dailyBookings;

  BookingData(this.month, this.bookings, this.yearlyTotal,
      {this.year = 2024, this.dailyBookings});

  factory BookingData.fromJson(Map<String, dynamic> json, int yearlyTotal) {
    List<DailyBooking>? dailyBookings;
    if (json.containsKey('dailyBookings')) {
      dailyBookings = (json['dailyBookings'] as List)
          .map((item) => DailyBooking.fromJson(item))
          .toList();
    }

    return BookingData(
      json['month'],
      json['bookings'],
      yearlyTotal,
      year: json['year'] ?? 2024,
      dailyBookings: dailyBookings,
    );
  }
}

class DailyBooking {
  final int day;
  final int bookings;

  DailyBooking(this.day, this.bookings);

  factory DailyBooking.fromJson(Map<String, dynamic> json) {
    return DailyBooking(json['day'], json['bookings']);
  }
}
