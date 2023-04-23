package experiment.example;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;

import javax.swing.*;
import java.awt.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class writeToMQTT {
    private static final MqttClient mqttclient;
    private static final String BROKER_URL = "tcp://localhost:1883";
    private volatile static boolean sendingData = true;
    private static final Object lock = new Object();

    static {
        try {
            mqttclient = new MqttClient(BROKER_URL, MqttClient.generateClientId());
        } catch (MqttException e) {
            throw new RuntimeException(e);
        }
    }

    public static void publishSensor(String topic, String message) {
        try {
            MqttMessage mqtt_message = new MqttMessage();
            mqtt_message.setPayload(message.getBytes());
            mqttclient.connect();
            mqttclient.publish(topic, mqtt_message);
        } catch (MqttException e) {
            e.printStackTrace();
        } finally {
            try {
                mqttclient.disconnect();
            } catch (MqttException e) {
                e.printStackTrace();
            }
        }
    }

    public static void main(String[] args) {
        String mov_topic = "pisid_mazemov";
        String temp_topic = "pisid_mazetemp";
        int sensorId = 1;
        double temperature = 9;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSS");
        Random rand = new Random(123456789);

        // Create the JFrame and buttons
        JFrame frame = new JFrame("Write to MQTT");
        JTextArea textArea = new JTextArea(20, 100);
        textArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        frame.getContentPane().add(new JScrollPane(textArea), BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout());
        JButton stopButton = new JButton("Stop Sending Data");
        JButton startButton = new JButton("Start Sending Data");
        buttonPanel.add(stopButton);
        buttonPanel.add(startButton);
        frame.getContentPane().add(buttonPanel, BorderLayout.SOUTH);

        frame.pack();
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setVisible(true);
        frame.setLocationRelativeTo(null);

        stopButton.addActionListener(e -> stopSendingData());
        startButton.addActionListener(e -> startSendingData());

        // Start sending data
        while (sendingData) {
            if (rand.nextDouble() < 0.2) {
                endExperience(mov_topic, formatter);
            } else {
                sendMovementData(mov_topic, rand, formatter, textArea);
                sendTemperatureData(temp_topic, rand, formatter, sensorId, temperature, textArea);
                temperature = rand.nextDouble() * 10;
            }
            try {
                Thread.sleep(300);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    private static void stopSendingData() {
        sendingData = false;
    }

    private static void startSendingData() {
        sendingData = true;
    }

    private static void endExperience(String topic, DateTimeFormatter formatter) {
        LocalDateTime now = LocalDateTime.now();
        String end_msg = "{Hour:\"" + formatter.format(now) + "\", from:" + 0 + ", to:" + 0 + "}";
        publishSensor(topic, end_msg);
    }

    private static void sendMovementData(String topic, Random rand, DateTimeFormatter formatter, JTextArea textArea) {
        int from = rand.nextInt(9) + 1;
        int to = rand.nextInt(9) + 1;
        LocalDateTime now = LocalDateTime.now();
        String mov_msg = "{Hour:\"" + formatter.format(now) + "\", from:" + from + ", to:" + to + "}";
        textArea.append(mov_msg + "\n");
        publishSensor(topic, mov_msg);
    }

    private static void sendTemperatureData(String topic, Random rand, DateTimeFormatter formatter, int sensorId, double temperature, JTextArea textArea) {
        LocalDateTime now = LocalDateTime.now();
        double tempValue1 = temperature;
        double tempValue2 = temperature;
        if (rand.nextDouble() < 0.1) {
            // Generate a high outlier
            tempValue1 += rand.nextDouble() * 50;
        } else if (rand.nextDouble() < 0.1) {
            // Generate a low outlier
            tempValue1 -= rand.nextDouble() * 50;
        }
        if (rand.nextDouble() < 0.1) {
            // Generate a high outlier
            tempValue2 += rand.nextDouble() * 50;
        } else if (rand.nextDouble() < 0.1) {
            // Generate a low outlier
            tempValue2 -= rand.nextDouble() * 50;
        }
        String temp_msg1 = "{Hour: \"" + formatter.format(now) + "\", Leitura: " + tempValue1 + ", Sensor: " + 1 + "}";
        String temp_msg2 = "{Hour: \"" + formatter.format(now) + "\", Leitura: " + tempValue2 + ", Sensor: " + 2 + "}";
        textArea.append(temp_msg1 + "\n");
        textArea.append(temp_msg2 + "\n");
        publishSensor(topic, temp_msg1);
        publishSensor(topic, temp_msg2);
    }

    // Method to notify the thread to resume execution
    public static void resumeSendingData() {
        synchronized (lock) {
            lock.notifyAll();
        }
    }

}