// SPDX-License-Identifier: AGPL-3.0-or-later
//
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "dss-exec-lib/DssExec.sol";
import "dss-exec-lib/DssAction.sol";
import { VatAbstract, LerpFactoryAbstract, SpotAbstract } from "dss-interfaces/Interfaces.sol";

contract DssSpellAction is DssAction {
    // Provides a descriptive tag for bot consumption
    // This should be modified weekly to provide a summary of the actions
    // Hash: seth keccak -- "$(wget https://raw.githubusercontent.com/makerdao/community/194592d74ae225132c1963527ae90190b8bfa476/governance/votes/Executive%20vote%20-%20November%2026,%202021.md -q -O - 2>/dev/null)"
    string public constant override description =
        "2021-12-03 MakerDAO Executive Spell | Hash: ??";
    // TODO: add in hash - PE handover

    // Many of the settings that change weekly rely on the rate accumulator
    // described at https://docs.makerdao.com/smart-contract-modules/rates-module
    // To check this yourself, use the following rate calculation (example 8%):
    //
    // $ bc -l <<< 'scale=27; e( l(1.08)/(60 * 60 * 24 * 365) )'
    //
    // A table of rates can be found at
    //    https://ipfs.io/ipfs/QmefQMseb3AiTapiAKKexdKHig8wroKuZbmLtPLv4u2YwW
    //

    // --- Rates ---
    uint256 constant ZERO_PCT_RATE           = 1000000000000000000000000000;
    uint256 constant ZERO_ONE_PCT_RATE       = 1000000000031693947650284507;
    uint256 constant ONE_PCT_RATE            = 1000000000315522921573372069;
    uint256 constant ONE_FIVE_PCT_RATE       = 1000000000472114805215157978;
    uint256 constant TWO_PCT_RATE            = 1000000000627937192491029810;
    uint256 constant TWO_FIVE_PCT_RATE       = 1000000000782997609082909351;
    uint256 constant TWO_SEVEN_FIVE_PCT_RATE = 1000000000860244400048238898;
    uint256 constant THREE_PCT_RATE          = 1000000000937303470807876289;
    uint256 constant FOUR_PCT_RATE           = 1000000001243680656318820312;
    uint256 constant SIX_PCT_RATE            = 1000000001847694957439350562;
    uint256 constant SIX_FIVE_PCT_RATE       = 1000000001996917783620820123;

    // --- Math ---
    uint256 constant MILLION = 10 ** 6;
    uint256 constant BILLION = 10 ** 3;
    uint256 constant RAD     = 10 ** 45;

    // --- GUNIV3DAIUSDC2-A ---
    address constant GUNIV3DAIUSDC2                 = 0x50379f632ca68D36E50cfBC8F78fe16bd1499d1e;
    address constant MCD_JOIN_GUNIV3DAIUSDC2_A      = address(0); // TODO: deploy from factory - std join
    address constant MCD_CLIP_GUNIV3DAIUSDC2_A      = address(0); // TODO: deploy from factory
    address constant MCD_CLIP_CALC_GUNIV3DAIUSDC2_A = address(0); // TODO: deploy from factory
    address constant PIP_GUNIV3DAIUSDC2             = address(0); // TODO: wait for the Oracle team to deploy it

    // --- Wallets ---
    address constant COM_WALLET               = 0x1eE3ECa7aEF17D1e74eD7C447CcBA61aC76aDbA9;
    address constant FLIPFLOPFLAP_WALLET      = 0x688d508f3a6B0a377e266405A1583B3316f9A2B3;
    address constant FEEDBACKLOOPS_WALLET     = 0x80882f2A36d49fC46C3c654F7f9cB9a2Bf0423e1;
    address constant ULTRASCHUPPI_WALLET      = 0x89C5d54C979f682F40b73a9FC39F338C88B434c6;
    address constant FIELDTECHNOLOGIES_WALLET = 0x0988E41C02915Fe1beFA78c556f946E5F20ffBD3;

    // Office Hours On
    function officeHours() public override returns (bool) {
        return true;
    }

    function actions() public override {
        // --- 2021-12-03 Weekly Executive ---

        // ----------------------------- Collateral onboarding -----------------------------
        //  Add GUNIV3DAIUSDC2-A as a new Vault Type
        //  https://vote.makerdao.com/polling/QmSkHE8T?network=mainnet#poll-detail
        DssExecLib.addNewCollateral(
            CollateralOpts({
                ilk:                   "GUNIV3DAIUSDC2-A",
                gem:                   GUNIV3DAIUSDC2,
                join:                  MCD_JOIN_GUNIV3DAIUSDC2_A,
                clip:                  MCD_CLIP_GUNIV3DAIUSDC2_A,
                calc:                  MCD_CLIP_CALC_GUNIV3DAIUSDC2_A,
                pip:                   PIP_GUNIV3DAIUSDC2, // TODO: maybe need new "2" PIP  -  confim with PE
                isLiquidatable:        false,
                isOSM:                 true,
                whitelistOSM:          true, // TODO:  confirm if new oracle is onboarded
                ilkDebtCeiling:        10 * MILLION,
                minVaultAmount:        10_000,
                maxLiquidationAmount:  5 * MILLION,
                liquidationPenalty:    1300,
                ilkStabilityFee:       ONE_PCT_RATE,
                startingPriceFactor:   10500,
                breakerTolerance:      9500,
                auctionDuration:       220 minutes,
                permittedDrop:         9000,
                liquidationRatio:      10500,
                kprFlatReward:         300,
                kprPctReward:          10
            })
        );

        DssExecLib.setStairstepExponentialDecrease(MCD_CLIP_CALC_GUNIV3DAIUSDC2_A, 120 seconds, 9990);
        DssExecLib.setIlkAutoLineParameters("GUNIV3DAIUSDC2-A", 10 * MILLION, 10 * MILLION, 8 hours);

        // ----------------------------- Rates updates -----------------------------
        // Increase the ETH-A Stability Fee from 2.5% to 2.75%
        DssExecLib.setIlkStabilityFee("ETH-A", TWO_SEVEN_FIVE_PCT_RATE, true);

        // Increase the ETH-B Stability Fee from 6.0% to 6.5%
        DssExecLib.setIlkStabilityFee("ETH-B", SIX_FIVE_PCT_RATE, true);

        // Increase the LINK-A Stability Fee from 1.5% to 2.5%
        DssExecLib.setIlkStabilityFee("LINK-A", TWO_FIVE_PCT_RATE, true);

        // Increase the MANA-A Stability Fee from 3.0% to 6.0%
        DssExecLib.setIlkStabilityFee("MANA-A", SIX_PCT_RATE, true);

        // Increase the UNI-A Stability Fee from 1.0% to 3.0%
        DssExecLib.setIlkStabilityFee("UNI-A", THREE_PCT_RATE, true);

        // Increase the GUSD-A Stability Fee from 0.0% to 1.0%
        DssExecLib.setIlkStabilityFee("GUSD-A", ONE_PCT_RATE, true);

        // Increase the UNIV2DAIETH-A Stability Fee from 1.5% to 2.0%
        DssExecLib.setIlkStabilityFee("UNIV2DAIETH-A", TWO_PCT_RATE, true);

        // Increase the UNIV2WBTCETH-A Stability Fee from 2.5% to 3.0%
        DssExecLib.setIlkStabilityFee("UNIV2WBTCETH-A", THREE_PCT_RATE, true);

        // Increase the UNIV2USDCETH-A Stability Fee from 2.0% to 2.5%
        DssExecLib.setIlkStabilityFee("UNIV2USDCETH-A", TWO_FIVE_PCT_RATE, true);

        // Increase the UNIV2UNIETH-A Stability Fee from 2.0% to 4.0%
        DssExecLib.setIlkStabilityFee("UNIV2UNIETH-A", FOUR_PCT_RATE, true);

        // Decrease the GUNIV3DAIUSDC1-A Stability Fee from 0.5% to 0.1%
        DssExecLib.setIlkStabilityFee("GUNIV3DAIUSDC1-A", ZERO_ONE_PCT_RATE, true);

        // ----------------------------- Debt Ceiling updates -----------------------------
        // Increase the WBTC-A Maximum Debt Ceiling (line) from 1.5 billion DAI to 2 billion DAI
        // Increase the WBTC-A Target Available Debt (gap) from 60 million DAI to 80 million DAI
        DssExecLib.setIlkAutoLineParameters("WBTC-A", 2 * BILLION, 80 * MILLION, 6 hours);

        // Increase the Dust Parameter from 30,000 DAI to 40,000 DAI for the ETH-B
        DssExecLib.setIlkMinVaultAmount("ETH-B", 40_000);

        // Increase the Dust Parameter from 10,000 DAI to 15,000 DAI for all vault-types excluding ETH-B and ETH-C
        DssExecLib.setIlkMinVaultAmount("ETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("USDC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("USDC-B", 15_000);
        DssExecLib.setIlkMinVaultAmount("TUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-B", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-C", 15_000);
        DssExecLib.setIlkMinVaultAmount("KNC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("MANA-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("USDT-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("PAXUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("LINK-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("YFI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("GUSD-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("RENBTC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("MATIC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2WBTCETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2USDCETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIUSDC-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2ETHUSDT-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2UNIETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2WBTCDAI-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2AAVEETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("UNIV2DAIUSDT-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("GUNIV3DAIUSDC1-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("GUNIV3DAIUSDC2-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WSTETH-A", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-B", 15_000);
        DssExecLib.setIlkMinVaultAmount("WBTC-C", 15_000);

        // ----------------------------- Budget distributions -----------------------------
        // Core Unit Budget Distributions
        DssExecLib.sendPaymentFromSurplusBuffer(COM_WALLET, 27_058);
        // Delegate Compensation Payments
        DssExecLib.sendPaymentFromSurplusBuffer(FLIPFLOPFLAP_WALLET, 12_000);
        DssExecLib.sendPaymentFromSurplusBuffer(FEEDBACKLOOPS_WALLET, 12_000);
        DssExecLib.sendPaymentFromSurplusBuffer(ULTRASCHUPPI_WALLET, 8_093);
        DssExecLib.sendPaymentFromSurplusBuffer(FIELDTECHNOLOGIES_WALLET, 3_690);


        // Changelog
        DssExecLib.setChangelogAddress("GUNIV3DAIUSDC2", GUNIV3DAIUSDC2);
        DssExecLib.setChangelogAddress("MCD_JOIN_GUNIV3DAIUSDC2_A", MCD_JOIN_GUNIV3DAIUSDC2_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_GUNIV3DAIUSDC2_A", MCD_CLIP_GUNIV3DAIUSDC2_A);
        DssExecLib.setChangelogAddress("MCD_CLIP_CALC_GUNIV3DAIUSDC2_A", MCD_CLIP_CALC_GUNIV3DAIUSDC2_A);
        DssExecLib.setChangelogAddress("PIP_GUNIV3DAIUSDC2", PIP_GUNIV3DAIUSDC2);

        DssExecLib.setChangelogVersion("1.9.12");
    }
}

contract DssSpell is DssExec {
    constructor() DssExec(block.timestamp + 30 days, address(new DssSpellAction())) public {}
}
