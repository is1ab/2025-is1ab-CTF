<?php
class TimeController
{
    public function index($router)
    {
        $format = isset($_GET['format']) ? $_GET['format'] : 'chw';
        $time = new TimeModel($format);
        return $router->view('index', ['time' => $time->getTime()]);
    }
}