package experiment.mice;

import javax.swing.*;
import java.awt.*;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Main {
    private static final Logger logger = Logger.getLogger(Main.class.getName());
    private static final String PROGRAM_START = "Start the Program";

    public static void main(String[] args) {
        logger.log(Level.INFO, "Starting the program");

        JFrame frame = new JFrame(PROGRAM_START);
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        frame.setSize(350, 350);
        frame.setLayout(new BorderLayout());

        CircularButton button = new CircularButton(PROGRAM_START, Color.GREEN);
        button.addActionListener(e -> {
            if(button.getText().equals(PROGRAM_START)) {
                try {
                    String[] sensoresCommand = {"cmd.exe", "/c", "cd C:\\Users\\wilio\\Documents\\GitHub\\PISID\\ReplicaSet_MongoDB && sensores_init.bat"};
                    ProcessBuilder sensoresBuilder = new ProcessBuilder(sensoresCommand);
                    sensoresBuilder.redirectErrorStream(true);
                    sensoresBuilder.start();
                    button.setText("Stop the Program");
                    button.setColor(Color.RED);
                } catch (IOException ioException) {
                    logger.log(Level.SEVERE, "Error starting the program", ioException);
                }
            } else {
                try {
                    String[] sensoresCommand = {"cmd.exe", "/c", "taskkill /F /IM python.exe"};
                    ProcessBuilder sensoresBuilder = new ProcessBuilder(sensoresCommand);
                    sensoresBuilder.redirectErrorStream(true);
                    sensoresBuilder.start();
                    button.setText(PROGRAM_START);
                    button.setColor(Color.GREEN);
                } catch (IOException ioException) {
                    logger.log(Level.SEVERE, "Error stopping the program", ioException);
                }
            }
        });

        JPanel panel = new JPanel();
        panel.setLayout(new FlowLayout(FlowLayout.CENTER));
        panel.setBorder(BorderFactory.createEmptyBorder(100, 0, 0, 0)); // add an empty border to center the button vertically
        panel.add(button);

        frame.add(panel, BorderLayout.CENTER);
        frame.setLocationRelativeTo(null);
        frame.setVisible(true);
    }

    static class CircularButton extends JButton {
        private Color color;

        public CircularButton(String label, Color color) {
            super(label);
            this.color = color;
            setContentAreaFilled(false);
            setFocusPainted(false);
            setBorderPainted(false);
            setOpaque(false);
            setPreferredSize(new Dimension(80, 80));
        }

        public void setColor(Color color) {
            this.color = color;
            repaint();
        }

        @Override
        protected void paintComponent(Graphics g) {
            Graphics2D g2 = (Graphics2D) g.create();
            g2.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
            g2.setColor(color);
            g2.fillOval(0, 0, getSize().width - 1, getSize().height - 1);
            super.paintComponent(g);
            g2.dispose();
        }
    }
}