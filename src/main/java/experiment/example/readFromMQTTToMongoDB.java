package experiment.example;

import com.mongodb.*;
import com.mongodb.util.JSON;
import com.mongodb.util.JSONParseException;
import org.eclipse.paho.client.mqttv3.*;

import javax.swing.*;
import java.awt.*;
import java.io.FileInputStream;
import java.util.Properties;
import java.util.Random;
import java.util.logging.Logger;
import java.util.logging.Level;


public class readFromMQTTToMongoDB implements MqttCallback{
    private static final String INI_FILE_NAME = "CloudToMongo.ini";
    private static final Logger logger = Logger.getLogger(readFromMQTTToMongoDB.class.getName());

    private DBCollection mongocolmov;
    private static DBCollection mongocoltemp;
    private static String mongoUser;
    private static String mongoPassword;
    private static String mongoAddress;
    private static String mongoReplica;
    private static String mongoDatabase;
    private static String cloudTopicMov = "pisid_mazemov";
    private static String cloudTopicTemp;
    private static String mongoAuthentication;
    private static String mongoCollectionMov;
    private static String mongoCollectionTemp;

    private final JTextArea documentLabel;

    private readFromMQTTToMongoDB() {
        documentLabel = new JTextArea("\n");
    }

    private void createWindow() {
        JFrame frame = new JFrame("Cloud to Mongo");
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);

        JLabel label = new JLabel("Data from broker: ", SwingConstants.CENTER);
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
        readFromMQTTToMongoDB cloudToMongo = new readFromMQTTToMongoDB();
        cloudToMongo.createWindow();

        System.out.println(INI_FILE_NAME);

        try (FileInputStream inputStream = new FileInputStream(INI_FILE_NAME)) {
            Properties properties = new Properties();
            properties.load(inputStream);

            mongoAddress = properties.getProperty("mongo_address");
            mongoUser = properties.getProperty("mongo_user");
            mongoPassword = properties.getProperty("mongo_password");
            mongoReplica = properties.getProperty("mongo_replica");
            String cloudServer = properties.getProperty("cloud_server");
            cloudTopicMov = properties.getProperty("cloud_topic_mov");
            cloudTopicTemp = properties.getProperty("cloud_topic_temp");
            mongoDatabase = properties.getProperty("mongo_database");
            mongoAuthentication = properties.getProperty("mongo_authentication");
            mongoCollectionMov = properties.getProperty("mongo_collection_mov");
            mongoCollectionTemp = properties.getProperty("mongo_collection_temp");

            cloudToMongo.connectCloud(cloudServer, cloudTopicMov, cloudTopicTemp);
            cloudToMongo.connectMongo();
        } catch (Exception e) {
            logger.info("Error reading " + INI_FILE_NAME + " file " + e);
            JOptionPane.showMessageDialog(null, "The " + INI_FILE_NAME + " file wasn't found.", "CloudToMongo", JOptionPane.ERROR_MESSAGE);
            System.exit(1);
        }
    }

    private void connectCloud(String cloudServer, String cloudTopicMov, String cloudTopicTemp) throws MqttException {
        int clientId = (new Random()).nextInt(100000);
        try (MqttClient mqttClient = new MqttClient(cloudServer, "CloudToMongo_" + clientId + "_" + cloudTopicMov)) {
            mqttClient.connect();
            mqttClient.setCallback(this);
            mqttClient.subscribe(cloudTopicMov);
            mqttClient.subscribe(cloudTopicTemp);
        }
    }

    public void connectMongo() {
        String mongoURI = "mongodb://";
        if (Boolean.parseBoolean(readFromMQTTToMongoDB.mongoAuthentication)) {
            mongoURI += readFromMQTTToMongoDB.mongoUser + ":" + readFromMQTTToMongoDB.mongoPassword + "@";
        }
        mongoURI += readFromMQTTToMongoDB.mongoAddress;

        if (!readFromMQTTToMongoDB.mongoReplica.equals("false")) {
            mongoURI += "/?replicaSet=" + readFromMQTTToMongoDB.mongoReplica;
            if (Boolean.parseBoolean(readFromMQTTToMongoDB.mongoAuthentication)) {
                mongoURI += "&authSource=admin";
            }
        } else if (Boolean.parseBoolean(readFromMQTTToMongoDB.mongoAuthentication)) {
            mongoURI += "/?authSource=admin";
        }

        MongoClientURI uri = new MongoClientURI(mongoURI);
        MongoClient mongoClient = new MongoClient(uri);
        DB db = mongoClient.getDB(readFromMQTTToMongoDB.mongoDatabase);
        mongocoltemp = db.getCollection(readFromMQTTToMongoDB.mongoCollectionTemp);
        mongocolmov = db.getCollection(readFromMQTTToMongoDB.mongoCollectionMov);
    }

    @Override
    public void messageArrived(String topic, MqttMessage message) {
        try {
            DBObject document_json = (DBObject) JSON.parse(message.toString());
            documentLabel.append(message + "\n");

            if (mongocoltemp != null && mongocolmov != null) {
                if (topic.equals(cloudTopicMov)) {
                    mongocolmov.insert(document_json);
                }
                if (topic.equals(cloudTopicTemp)) {
                    mongocoltemp.insert(document_json);
                }
            }
        } catch (JSONParseException e) {
            logger.warning("Error parsing JSON message: " + e.getMessage());
            logger.warning("JSON message: " + message);
        } catch (Exception e) {
            logger.log(Level.SEVERE, "The following exception was launched: ", e);
            System.exit(1);
        }
    }

    @Override
    public void connectionLost(Throwable cause) {
        logger.log(Level.WARNING, "Connection to MQTT broker lost. Reason: {0}", cause.getMessage());
        logger.log(Level.SEVERE, "Stack trace: ", cause);
    }

    @Override
    public void deliveryComplete(IMqttDeliveryToken token) {
        try {
            logger.log(Level.INFO, "Message delivery complete: {0}", token.getMessage());
        } catch (MqttException e) {
            logger.log(Level.SEVERE, "Error getting message from delivery token: {0}", e.getMessage());
        }
    }
}
