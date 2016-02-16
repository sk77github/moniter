<?php
// 测试相关
namespace app\commands;
use app\common\Statsd;

class HelloController extends Controller
{
    public function actionTestCounter()
    {
        # 获取当前运行主机名
        if (is_array($_SERVER) && isset($_SERVER['HOSTNAME']))
        {
            define('HOST_NAME', $_SERVER['HOSTNAME']);
        }
        else
        {
            define('HOST_NAME', php_uname('n'));
        }
        $metricName = 'test.' . HOST_NAME . '.concurrent';
        while(True)
        {
            Statsd::increment($metricName);
            usleep(rand(5000, 100000));
        }
    }

    public function actionTestTimer()
    {
        # 获取当前运行主机名
        if (is_array($_SERVER) && isset($_SERVER['HOSTNAME']))
        {
            define('HOST_NAME', $_SERVER['HOSTNAME']);
        }
        else
        {
            define('HOST_NAME', php_uname('n'));
        }
        $metricName = 'test.' . HOST_NAME . '.elapsed';
        while(True)
        {
            Statsd::timing($metricName, rand(5000, 10000000) / 1000);
            usleep(50000);
        }
    }

    public function actionTestGauge()
    {
        # 获取当前运行主机名
        if (is_array($_SERVER) && isset($_SERVER['HOSTNAME']))
        {
            define('HOST_NAME', $_SERVER['HOSTNAME']);
        }
        else
        {
            define('HOST_NAME', php_uname('n'));
        }
        $metricName = 'test.' . HOST_NAME . '.gauge';
        while(True)
        {
            Statsd::gauge($metricName, rand(100, 500));
        }
    }
}
