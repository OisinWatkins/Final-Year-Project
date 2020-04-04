# Final-Year-Project
An Application of 24GHz RADAR for Contactless Heart-Rate Monitoring

### Basic Idea
The plan is to use the Multiple-Input Multiple-Output (MIMO) capabilities of the Inras Demorad, operating in 
Frequency Modulated Continuous Wave (FMCW) mode to read the heart rate of a human subject from a distance of 1m.
This project would be determined a success if the measurment maintained an error no greater than 10% from a standard monitor.

### Implementation
Using the customer scripts that Inras have provided, I modified their code to save a buffer of measurement readings.
The script will find the most prominent target in the Field of View (given that these tests were conducted in an Anechoic Chamber,
the only prominent taregt will be the human subject) and measure the distance to that target. By watching the distance to the subject's
chest over time, we can perform an FFT on these distance readings and extract information pertaining to both Heart Rate and
Respiration.

### Gold Standard
To test the accuracy of the final code set, an SpO2 monitor was attached to the subject's right index finger. This being a medical
industry standard, it was used as the baseline for accuracy in these experiments. The monitor yielded a graph of heart rate over time,
from which we extroplated data points to compare with our readings.

### Results
After performing some statistical analysis of this experiment, the Mean Absolute Percentage Error (MAPE) was decided to be the 
best comparison metric. The final results show a MAPE of roughly 5%, meaning the final design has indeed passed by the initial 
project outline.
