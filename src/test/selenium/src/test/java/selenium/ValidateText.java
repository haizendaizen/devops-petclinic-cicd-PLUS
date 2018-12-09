package selenium;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.By;
import org.junit.Assert;

public class ValidateText {

	private static WebDriver driver;

	@BeforeClass
	public static void startDriver() {
		driver = Utils.getDriver();
	}
	
	@Test
	public void test_case_1() {
	 driver.get(Utils.getBaseUrl());
	 String actualStr = driver.findElement(By.xpath("/html/body/div/div/h3[1]")).getText();
	 String actualTitle = driver.getTitle();
         
        // check_app_version
	 Assert.assertEquals("Condition true", "PetClinic v1.1", actualStr);

	// check_title_text
	 Assert.assertEquals("Condition true", "PetClinic :: a Spring Framework demonstration", actualTitle);

	 driver.close();
	}
	
	@AfterClass
	public static void stopDriver() {
		driver.quit();
	}
}
