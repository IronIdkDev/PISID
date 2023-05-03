package experiment.mice;

import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MqttDefaultFilePersistence;

import javax.swing.*;
import java.awt.*;
import java.io.File;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Random;

public class writeToMQTT {
    private static final MqttClient mqttclient;
    private static final String BROKER_URL = "tcp://localhost:1883";

    static {
        try {
            mqttclient = new MqttClient(BROKER_URL, MqttClient.generateClientId(), new MqttDefaultFilePersistence(System.getProperty("user.dir") + File.separator+ "tmp"));
        } catch (MqttException e) {
            throw new RuntimeException(e);
        }
    }

    public static void publishSensor(String topic, String message) {
        try {
            MqttMessage mqtt_message = new MqttMessage();
            mqtt_message.setPayload(message.getBytes());
            mqttclient.publish(topic, mqtt_message);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        String mov_topic = "pisid_mazemov";
        String temp_topic = "pisid_mazetemp";
        int sensorId = 1;
        double temperature = 9;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSS");
        Random rand = new Random(123456789);


        // Create the MQTT client
        try {
            mqttclient.connect();
        } catch (MqttException e) {
            e.printStackTrace();
            return;
        }

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

        // Start sending data
        while (true) {
            if (rand.nextDouble() < 0.05) {
                endExperience(mov_topic, formatter);
            } else {
                sendMovementData(mov_topic, rand, formatter, textArea);
                sendTemperatureData(temp_topic, rand, formatter, sensorId, temperature, textArea);
                temperature = rand.nextDouble() * 10;
            }
            try {
                Thread.sleep(300);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
        }
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
        } else if (rand.nextDouble() > 0.1 && rand.nextDouble() < 0.2) {
            // Generate a low outlier
            tempValue1 -= rand.nextDouble() * 50;
        }
        if (rand.nextDouble() > 0.9) {
            // Generate a high outlier
            tempValue2 += rand.nextDouble() * 50;
        } else if (rand.nextDouble() < 0.9 && rand.nextDouble() > 0.8) {
            // Generate a low outlier
            tempValue2 -= rand.nextDouble() * 50;
        }
        String temp_msg1 = "{Hour: \"" + formatter.format(now) + "\", Leitura: " + tempValue1 + ", Sensor: " + 1 + "}";
        String temp_msg2 = "{Hour: \"" + formatter.format(now) + "\", Leitura: " + tempValue2 + ", Sensor: " + 2 + "}";
        textArea.append(temp_msg1 + "\n");
        textArea.append(temp_msg2 + "\n");
        publishSensor(topic, temp_msg1);
        publishSensor(topic, temp_msg2);
        String test_msg = "{Hour: \"" + formatter.format(now) + "\", Leitura: 3@" + ' ' + ", Sensor: " + 2 + "}";
        textArea.append(test_msg + "\n");
        publishSensor(topic, test_msg);
    }

}