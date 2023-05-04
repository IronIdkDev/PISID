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
        startUIandAuthentication();
    }

    private static void startUIandAuthentication() {
        try {
            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException | UnsupportedLookAndFeelException e) {
            e.printStackTrace();
        }

        // User Authentication
        String username = JOptionPane.showInputDialog(null, "Enter your username:");
        String password = JOptionPane.showInputDialog(null, "Enter your password:");

        // Check whether the entered username and password are correct
        if (username.equals("admin") && password.equals("password")) {
            JFrame frame = new JFrame(PROGRAM_START);
            frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
            frame.setSize(500, 500);
            frame.setLayout(new BorderLayout());

            CircularButton button = new CircularButton(PROGRAM_START, Color.GREEN);
            button.addActionListener(e -> {
                if(button.getText().equals(PROGRAM_START)) {
                    try {
                        startServers(button);
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
        } else {
            JOptionPane.showMessageDialog(null, "Invalid username or password.");
        }
    }

    private static void startServers(CircularButton button) throws IOException {
        String[] sensoresCommand = {"cmd.exe", "/c", "cd C:\\Users\\wilio\\Documents\\GitHub\\PISID\\ReplicaSet_MongoDB && sensores_init.bat"};
        ProcessBuilder sensoresBuilder = new ProcessBuilder(sensoresCommand);
        sensoresBuilder.redirectErrorStream(true);
        sensoresBuilder.start();
        button.setText("Stop the Program");
        button.setColor(Color.RED);
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
            setPreferredSize(new Dimension(300, 80)); // adjust the preferred size to fit the text
            setFont(getFont().deriveFont(16f));
            setHorizontalTextPosition(SwingConstants.CENTER);
            setVerticalTextPosition(SwingConstants.CENTER);
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
            int diameter = Math.min(getWidth(), getHeight());
            g2.fillRoundRect((getWidth() - diameter) / 2, (getHeight() - diameter) / 2, diameter, diameter, diameter, diameter); // use a rounded rectangle shape
            super.paintComponent(g);
            g2.dispose();
        }
    }
}