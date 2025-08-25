<?php
class TimeModel
{
    public function __construct($format)
    {
        $this->format = addslashes($format);
        $offset_seconds = 8 * 3600;

        $current_utc_time = gmdate('Y-m-d H:i:s');
        $prediction_time = date('Y-m-d H:i:s', strtotime($current_utc_time) + $offset_seconds);

        $this->prediction = $prediction_time;
    }

    public function getTime()
    {
        eval('$time = date("' . $this->format . '", strtotime("' . $this->prediction . '"));');
        return isset($time) ? $time : 'Something went terribly wrong';
    }
}

// Example usage:
$format = 'Y-m-d H:i:s';
$model = new TimeModel($format);
echo $model->getTime(); // Output: Predicted time formatted according to $format
?>
