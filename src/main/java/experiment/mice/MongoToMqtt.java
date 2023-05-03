package experiment.mice;

import com.mongodb.client.MongoCollection;
import org.bson.Document;
import org.eclipse.paho.client.mqttv3.MqttClient;
import org.eclipse.paho.client.mqttv3.MqttException;
import org.eclipse.paho.client.mqttv3.MqttMessage;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;

import javax.swing.*;
import java.awt.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MongoToMqtt {

    // MQTT broker URL
    private static final String BROKER_URL = "tcp://localhost:1883";

    // MQTT topic to publish data to
    private static final String MQTT_TOPIC = "replicaset-data";

    // MQTT topic for movement data
    private static String cloudTopicMov = "pisid_mazemov";
    // MQTT topic for temperature data
    private static String cloudTopicTemp = "pisid_mazetemp";
    // MQTT topic for Outliers Data
    private static String outliersTopic = "pisid_outliers";

    // MongoDB database name
    private static final String DB_NAME = "sensores";

    // MongoDB collections to read data from
    private static final String[] COLLECTIONS = {"Outliers", "SensoresMovimento", "SensoresTemperatura"};
    private static final Logger logger = Logger.getLogger(MongoToMqtt.class.getName());

    private final JTextArea documentLabel;

    private MongoToMqtt() {
        documentLabel = new JTextArea("\n");
    }

    private void createWindow() {
        JFrame frame = new JFrame("Mongo To MQTT");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        JLabel label = new JLabel("Data sent to broker: ", SwingConstants.CENTER);
        label.setPreferredSize(new Dimension(600, 30));

        JScrollPane scrollPane = new JScrollPane(documentLabel, ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS, ScrollPaneConstants.HORIZONTAL_SCROLLBAR_ALWAYS);
        scrollPane.setPreferredSize(new Dimension(600, 200));

        JButton button = new JButton("Stop the program");
        button.addActionListener(e -> System.exit(0));

        frame.getContentPane().add(label, BorderLayout.NORTH);
        frame.getContentPane().add(scrollPane, BorderLayout.CENTER);
        frame.getContentPane().add(button, BorderLayout.SOUTH);

        frame.setLocationRelativeTo(null);
        frame.pack();
        frame.setVisible(true);
    }

    public static void main(String[] args) {
        MongoToMqtt mongoToMqtt = new MongoToMqtt();
        mongoToMqtt.createWindow();
        //mongoToMqtt.connectToMqttServer(BROKER_URL, cloudTopicMov, cloudTopicTemp);
        //cloudToMongo.connectMongo();
    }
}