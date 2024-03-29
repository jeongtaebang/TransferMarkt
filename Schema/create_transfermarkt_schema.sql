-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema TransferMarkt_sp20
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema TransferMarkt_sp20
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `TransferMarkt_sp20` DEFAULT CHARACTER SET latin1 ;
USE `TransferMarkt_sp20` ;

-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Leagues`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Leagues` (
  `LeagueID` INT(11) NOT NULL AUTO_INCREMENT,
  `LeagueName` VARCHAR(45) NOT NULL,
  `SalaryCap` INT(11) NOT NULL,
  PRIMARY KEY (`LeagueID`))
ENGINE = InnoDB
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Clubs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Clubs` (
  `ClubID` INT(11) NOT NULL AUTO_INCREMENT,
  `ClubName` VARCHAR(150) NOT NULL,
  `LeagueID` INT(11) NOT NULL,
  PRIMARY KEY (`ClubID`),
  INDEX `fk_Clubs_League1_idx` (`LeagueID` ASC) ,
  CONSTRAINT `fk_Clubs_League1`
    FOREIGN KEY (`LeagueID`)
    REFERENCES `TransferMarkt_sp20`.`Leagues` (`LeagueID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 21
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Managers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Managers` (
  `ManagerID` INT(11) NOT NULL AUTO_INCREMENT,
  `AdminPrivilege` INT(11) NOT NULL,
  `Username` VARCHAR(45) NOT NULL,
  `SaltedPassword` VARCHAR(300) NOT NULL,
  `ClubID` INT(11) NOT NULL,
  PRIMARY KEY (`ManagerID`),
  INDEX `fk_Managers_Clubs1_idx` (`ClubID` ASC) ,
  CONSTRAINT `fk_Managers_Clubs1`
    FOREIGN KEY (`ClubID`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 21
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Packages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Packages` (
  `PackageID` VARCHAR(40) NOT NULL,
  `Status` INT(11) NOT NULL,
  `Date` DATE NOT NULL,
  PRIMARY KEY (`PackageID`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Players`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Players` (
  `PlayerID` INT(11) NOT NULL AUTO_INCREMENT,
  `FirstName` VARCHAR(30) NOT NULL,
  `LastName` VARCHAR(30) NOT NULL,
  `Age` INT(11) NOT NULL,
  `Salary` INT(11) NOT NULL,
  `ClubID` INT(11) NOT NULL,
  PRIMARY KEY (`PlayerID`),
  INDEX `fk_Players_Clubs1_idx` (`ClubID` ASC) ,
  CONSTRAINT `fk_Players_Clubs1`
    FOREIGN KEY (`ClubID`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
AUTO_INCREMENT = 628
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Positions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Positions` (
  `PositionID` INT(11) NOT NULL AUTO_INCREMENT,
  `PositionName` VARCHAR(30) NOT NULL,
  PRIMARY KEY (`PositionID`))
ENGINE = InnoDB
AUTO_INCREMENT = 16
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`PlayerPositions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`PlayerPositions` (
  `PlayerID` INT(11) NOT NULL,
  `PositionID` INT(11) NOT NULL,
  PRIMARY KEY (`PlayerID`, `PositionID`),
  INDEX `fk_Players_has_Positions_Positions1_idx` (`PositionID` ASC) ,
  INDEX `fk_Players_has_Positions_Players_idx` (`PlayerID` ASC) ,
  CONSTRAINT `fk_Players_has_Positions_Players`
    FOREIGN KEY (`PlayerID`)
    REFERENCES `TransferMarkt_sp20`.`Players` (`PlayerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Players_has_Positions_Positions1`
    FOREIGN KEY (`PositionID`)
    REFERENCES `TransferMarkt_sp20`.`Positions` (`PositionID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Requests`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Requests` (
  `RequestID` INT(11) NOT NULL AUTO_INCREMENT,
  `From` INT(11) NOT NULL,
  `To` INT(11) NOT NULL,
  `PlayerID` INT(11) NOT NULL,
  `TransferFee` INT(11) NOT NULL,
  `NewSalary` INT(11) NOT NULL,
  `DateOfRequest` DATE NOT NULL,
  `PackageID` VARCHAR(40) NOT NULL,
  PRIMARY KEY (`RequestID`),
  INDEX `fk_Requests_Players1_idx` (`PlayerID` ASC) ,
  INDEX `fk_Requests_Clubs1_idx` (`To` ASC) ,
  INDEX `fk_Requests_Clubs2_idx` (`From` ASC) ,
  INDEX `fk_Requests_Packages1_idx` (`PackageID` ASC) ,
  CONSTRAINT `fk_Requests_Clubs_FROM`
    FOREIGN KEY (`From`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Clubs_TO`
    FOREIGN KEY (`To`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Packages1`
    FOREIGN KEY (`PackageID`)
    REFERENCES `TransferMarkt_sp20`.`Packages` (`PackageID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Players1`
    FOREIGN KEY (`PlayerID`)
    REFERENCES `TransferMarkt_sp20`.`Players` (`PlayerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Transfers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Transfers` (
  `PackageID` VARCHAR(40) NOT NULL,
  `DateSigned` DATE NOT NULL,
  PRIMARY KEY (`PackageID`),
  CONSTRAINT `fk_Transfers_Packages1`
    FOREIGN KEY (`PackageID`)
    REFERENCES `TransferMarkt_sp20`.`Packages` (`PackageID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = latin1;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Signatures`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Signatures` (
  `PackageID` VARCHAR(40) NOT NULL,
  `ClubID` INT(11) NOT NULL,
  `Status` INT(11) NOT NULL,
  PRIMARY KEY (`PackageID`, `ClubID`),
  INDEX `fk_Signatures_Clubs1_idx` (`ClubID` ASC) ,
  CONSTRAINT `fk_Signatures_Packages1`
    FOREIGN KEY (`PackageID`)
    REFERENCES `TransferMarkt_sp20`.`Packages` (`PackageID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Signatures_Clubs1`
    FOREIGN KEY (`ClubID`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
