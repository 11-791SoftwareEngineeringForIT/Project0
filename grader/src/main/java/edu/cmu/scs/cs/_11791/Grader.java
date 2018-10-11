package edu.cmu.scs.cs._11791;

import edu.cmu.scs.cc.grader.Config;
import edu.cmu.scs.cc.grader.GradingProcessor;
import edu.cmu.scs.cc.grader.strategy.JsonGradeStrategy;

public class Grader {
    /**
     * When the grader is executed with command
     * <pre>java -jar java_grader.jar</pre>
     * <em>localMode</em> will be set to <b>true</b><br>
     *
     * When the grader is executed with command
     * <pre>java -jar java_grader.jar submissionFolder submissionFilename
     * feedbackFile scoreFile logFile graderFolder</pre>
     * <em>localMode</em> will be set to <b>false</b><br>
     *
     * AGS will always execute the grader with args and <em>localMode</em>
     * will be <b>false</b>
     *
     * @param args option args
     */
    public static void main(String[] args) {
        // init the config
        Config config = new Config(args);

        // create 1 or more GradeStrategy instance(s)
        JsonGradeStrategy jsonGradeStrategy =
                new JsonGradeStrategy(config, "/reference.yaml");

        // pass GradeStrategy instance(s) into the GradingProcessor constructor
        GradingProcessor gradingProcessor = new GradingProcessor(
                config, jsonGradeStrategy);

        // and run the GradingProcessor
        gradingProcessor.run();
    }
}
