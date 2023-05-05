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
import java.util.logging.Logger;
import java.util.logging.Level;

public class WriteToMqtt {
    private static MqttClient mqttclient;
    private static final String BROKER_URL = "tcp://localhost:1883";
    private static Thread dataThread;
    private static volatile boolean running = true;
    private static final String HOUR_PREFIX = "{Hour: \"";
    private static final String SENSOR_PREFIX = ", Sensor: ";
    private static final Logger logger = Logger.getLogger(WriteToMqtt.class.getName());

    static {
        try {
            mqttclient = new MqttClient(BROKER_URL, MqttClient.generateClientId(), new MqttDefaultFilePersistence(System.getProperty("user.dir") + File.separator+ "tmp"));
        } catch (MqttException e) {
            logger.log(Level.SEVERE, String.format("Error creating client %s", e.getMessage()));
        }
    }

    public static void publishSensor(String topic, String message) {
        try {
            MqttMessage mqttMessage = new MqttMessage();
            mqttMessage.setPayload(message.getBytes());
            mqttclient.publish(topic, mqttMessage);
        } catch (MqttException e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        String movTopic = "pisid_mazemov";
        String tempTopic = "pisid_mazetemp";

        double temperature = 9;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss.SSSSSS");
        Random rand = new Random(123456789);


        // Create the MQTT client
        try {
            if (!mqttclient.isConnected()) {
                mqttclient.connect();
            }
        } catch (MqttException e) {
            e.printStackTrace();
            return;
        }

        JTextArea textArea = getjTextArea();

        // Start sending data
        while (running) {
            if (rand.nextDouble() < 0.05) {
                endExperience(movTopic, formatter, textArea);
            } else {
                sendMovementData(movTopic, rand, formatter, textArea);
                sendTemperatureData(tempTopic, rand, formatter, temperature, textArea);
                temperature = rand.nextDouble() * 10;
            }
            synchronized (WriteToMqtt.class) {
                try {
                    WriteToMqtt.class.wait(5000);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                }
            }
        }
    }

    private static JTextArea getjTextArea() {

        // Set Look and Feel to make the UI look more modern
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | UnsupportedLookAndFeelException e) {
            logger.log(Level.SEVERE, "Error setting the look and feel", e);
        }

        // Create the JFrame and buttons
        JFrame frame = new JFrame("Write to MQTT");
        JTextArea textArea = new JTextArea(20, 100);
        textArea.setFont(new Font("Monospaced", Font.PLAIN, 14));
        frame.getContentPane().add(new JScrollPane(textArea), BorderLayout.CENTER);

        JPanel buttonPanel = new JPanel(new FlowLayout());
        JButton stopButton = new JButton("Stop Sending Data");
        JButton resumeButton = new JButton("Resume Sending Data");
        buttonPanel.add(stopButton);
        buttonPanel.add(resumeButton);
        frame.getContentPane().add(buttonPanel, BorderLayout.SOUTH);

        frame.pack();
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        frame.setVisible(true);
        frame.setLocationRelativeTo(null);

        // Stop sending data when the stop button is pressed
        stopButton.addActionListener(e -> running = false);

        // Resume sending data when the start button is pressed
        resumeButton.addActionListener(e -> {
            running = true;
            if (dataThread != null) {
                dataThread.interrupt();
            }
            dataThread = new Thread(() -> main(null));
            dataThread.start();
        });

        return textArea;
    }


    private static void endExperience(String topic, DateTimeFormatter formatter, JTextArea textArea) {
        LocalDateTime now = LocalDateTime.now();
        String endMsg = "{Hour:\"" + formatter.format(now) + "\", from:" + 0 + ", to:" + 0 + "}";
        textArea.append(endMsg + "\n");
        publishSensor(topic, endMsg);
    }

    private static void sendMovementData(String topic, Random rand, DateTimeFormatter formatter, JTextArea textArea) {
        int from = rand.nextInt(9) + 1;
        int to = rand.nextInt(9) + 1;
        LocalDateTime now = LocalDateTime.now();
        String movMsg = HOUR_PREFIX + formatter.format(now) + "\", from:" + from + ", to:" + to + "}";
        textArea.append(movMsg + "\n");
        publishSensor(topic, movMsg);
    }

    private static void sendTemperatureData(String topic, Random rand, DateTimeFormatter formatter, double temperature, JTextArea textArea) {
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
        String tempMsg1 = HOUR_PREFIX + formatter.format(now) + "\", Leitura: " + tempValue1 + SENSOR_PREFIX + 1 + "}";
        String tempMsg2 = HOUR_PREFIX + formatter.format(now) + "\", Leitura: " + tempValue2 + SENSOR_PREFIX + 2 + "}";
        textArea.append(tempMsg1 + "\n");
        textArea.append(tempMsg2 + "\n");
        publishSensor(topic, tempMsg1);
        publishSensor(topic, tempMsg2);
        if(rand.nextDouble() > 0.95){
            String testMsg = HOUR_PREFIX + formatter.format(now) + "\", Leitura: 3@" + ' ' + SENSOR_PREFIX + 2 + "}";
            textArea.append(testMsg + "\n");
            publishSensor(topic, testMsg);
        }
    }

}