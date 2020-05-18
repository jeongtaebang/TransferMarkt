-- This schema is as edited version of the forward engineering script. Edited to work with MariaDB
-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema TransferMarkt_sp20
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema TransferMarkt_sp20
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `TransferMarkt_sp20` DEFAULT CHARACTER SET utf8 ;
USE `TransferMarkt_sp20` ;

-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Leagues`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Leagues` (
  `LeagueID` INT NOT NULL,
  `LeagueName` VARCHAR(45) NULL,
  `MinPlayersPerTeam` INT NULL,
  `SalaryCap` INT NULL,
  PRIMARY KEY (`LeagueID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Clubs`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Clubs` (
  `ClubID` INT NOT NULL,
  `ClubName` VARCHAR(150) NULL,
  `LeagueID` INT NOT NULL,
  PRIMARY KEY (`ClubID`, `LeagueID`),
  INDEX `fk_Clubs_League1_idx` (`LeagueID` ASC) ,
  CONSTRAINT `fk_Clubs_League1`
    FOREIGN KEY (`LeagueID`)
    REFERENCES `TransferMarkt_sp20`.`Leagues` (`LeagueID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Players`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Players` (
  `PlayerID` INT NOT NULL,
  `FirstName` VARCHAR(30) NULL,
  `LastName` VARCHAR(30) NULL,
  `Age` INT NULL,
  `Salary` INT NULL,
  `ClubID` INT NULL,
  PRIMARY KEY (`PlayerID`),
  INDEX `fk_Players_Clubs1_idx` (`ClubID` ASC),
  CONSTRAINT `fk_Players_Clubs1`
    FOREIGN KEY (`ClubID`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE SET NULL
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Positions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Positions` (
  `PositionID` INT NOT NULL,
  `PositionName` VARCHAR(30) NULL,
  PRIMARY KEY (`PositionID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`PlayerPositions`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`PlayerPositions` (
  `PlayerID` INT NOT NULL,
  `PositionID` INT NOT NULL,
  PRIMARY KEY (`PlayerID`, `PositionID`),
  INDEX `fk_Players_has_Positions_Positions1_idx` (`PositionID` ASC),
  INDEX `fk_Players_has_Positions_Players_idx` (`PlayerID` ASC),
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
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Managers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Managers` (
  `ManagerID` INT NOT NULL,
  `AdminPrivilege` INT NULL,
  `Username` VARCHAR(45) NULL,
  `SaltedPassword` VARCHAR(300) NULL,
  `ClubID` INT NOT NULL,
  PRIMARY KEY (`ManagerID`),
  INDEX `fk_Managers_Clubs1_idx` (`ClubID` ASC) ,
  CONSTRAINT `fk_Managers_Clubs1`
    FOREIGN KEY (`ClubID`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Packages`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Packages` (
  `PackageID` INT NOT NULL,
  `Status` VARCHAR(45) NULL,
  PRIMARY KEY (`PackageID`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Requests`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Requests` (
  `RequestID` INT NOT NULL,
  `From` INT NOT NULL,
  `To` INT NOT NULL,
  `PlayerID` INT NOT NULL,
  `RequestType` VARCHAR(45) NULL,
  `TransferFee` INT NULL,
  `NewSalary` INT NULL,
  `DateOfRequest` DATETIME NULL,
  `Packages_PackageID` INT NOT NULL,
  PRIMARY KEY (`RequestID`, `PlayerID`, `To`, `From`, `Packages_PackageID`),
  INDEX `fk_Requests_Packages1_idx` (`Packages_PackageID` ASC) ,
  INDEX `fk_Requests_Clubs1_idx` (`From` ASC) ,
  INDEX `fk_Requests_Clubs2_idx` (`To` ASC) ,
  INDEX `fk_Requests_Players1_idx` (`PlayerID` ASC) ,
  CONSTRAINT `fk_Requests_Packages1`
    FOREIGN KEY (`Packages_PackageID`)
    REFERENCES `TransferMarkt_sp20`.`Packages` (`PackageID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Clubs1`
    FOREIGN KEY (`From`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Clubs2`
    FOREIGN KEY (`To`)
    REFERENCES `TransferMarkt_sp20`.`Clubs` (`ClubID`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `fk_Requests_Players1`
    FOREIGN KEY (`PlayerID`)
    REFERENCES `TransferMarkt_sp20`.`Players` (`PlayerID`)
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `TransferMarkt_sp20`.`Transfers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `TransferMarkt_sp20`.`Transfers` (
  `PackageID` INT NOT NULL,
  `Date_Signed` DATETIME NULL,
  PRIMARY KEY (`PackageID`),
  CONSTRAINT `fk_Transfers_Packages1`
    FOREIGN KEY (`PackageID`)
    REFERENCES `TransferMarkt_sp20`.`Packages` (`PackageID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
