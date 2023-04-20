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
        int from = 1;
        int to = 3;
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


        // Add action listeners to the buttons
        stopButton.addActionListener(e -> sendingData = false);

        startButton.addActionListener(e -> {
            sendingData = true;
            resumeSendingData();
        });

        // Start sending data
        while (sendingData) {
            LocalDateTime now = LocalDateTime.now();
            if (rand.nextDouble() < 0.2) { // randomly end an experience with 20% probability
                String end_msg = "{hour:" + formatter.format(now) + ", from:0, to:0}";
                publishSensor(mov_topic, end_msg);
            } else {
                String mov_msg = "movimentação ratos: {hour:" + formatter.format(now) + ", from:" + from + ", to:" + to + "}";
                textArea.append(mov_msg + "\n");
                publishSensor(mov_topic, mov_msg);
                String temp_msg = "temperatura: " + sensorId + ", " + formatter.format(now) + ", " + temperature;
                textArea.append(temp_msg + "\n");
                publishSensor(temp_topic, temp_msg);
            }
            try {
                synchronized (lock) {
                    lock.wait(1000);
                }
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
    }

    // Method to notify the thread to resume execution
    public static void resumeSendingData() {
        synchronized (lock) {
            lock.notifyAll();
        }
    }

}