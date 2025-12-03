package;

class Rating {
    public static var ratingMap:Map<Int, String> = [
        22 => "Perfect",
        45 => "Marvelous",
        90 => "Great",
        135 => "Good",
        155 => "Ok",
        180 => "Bad"
    ];

    public static function rate(time:Float) {
        for (num in ratingMap.keys()) {
            if (time <= num) {
                return ratingMap[num];
            }
        }

        return "Bad";
    }
}