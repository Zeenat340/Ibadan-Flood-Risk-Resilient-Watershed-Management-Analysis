select *
from ibadan_flood_data;

-- Business questions 
-- 1. Which LGAs are the most flood-prone?
--Rank LGAs by flood incidents, population affected, severity, duration and economic loss.

SELECT 
    lga,
    SUM(flood_incidents) AS total_flood_incidents,
    SUM(population_affected) AS total_population_affected,
    AVG(flood_severity_1_5) AS avg_severity,
    AVG(flood_duration_hr) AS avg_duration,
    SUM(economic_loss_m_ngn) AS total_economic_loss,
    RANK() OVER(ORDER BY SUM(flood_incidents) DESC) AS flood_rank
FROM ibadan_flood_data
GROUP BY lga
ORDER BY total_flood_incidents DESC;

--2. What are the major causes of flooding in Ibadan?
-- Determine whether rainfall, drainage blockage, solid waste, floodplain encroachment, wetland loss or urban runoff is the dominant driver by LGA and year.

SELECT 
    lga,
    year,
    AVG(rainfall_mm) AS avg_rainfall,
    AVG(drainage_blockage_pct) AS avg_drainage,
    AVG(waste_blockage_level_pct) AS avg_waste,
    AVG(floodplain_encroachment_pct) AS avg_floodplain,
    AVG(wetland_loss_index_pct) AS avg_wetland_loss,
    AVG(impervious_surface_pct) AS avg_urban_runoff,
    CASE 
        WHEN AVG(drainage_blockage_pct) >= AVG(waste_blockage_level_pct)
        AND AVG(drainage_blockage_pct) >= AVG(floodplain_encroachment_pct)
        AND AVG(drainage_blockage_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(drainage_blockage_pct) >= AVG(impervious_surface_pct)
            THEN 'Drainage Blockage'
        WHEN AVG(waste_blockage_level_pct) >= AVG(floodplain_encroachment_pct)
        AND AVG(waste_blockage_level_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(waste_blockage_level_pct) >= AVG(impervious_surface_pct)
            THEN 'Solid Waste Blockage'
        WHEN AVG(floodplain_encroachment_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(floodplain_encroachment_pct) >= AVG(impervious_surface_pct)
            THEN 'Floodplain Encroachment'
        WHEN AVG(wetland_loss_index_pct) >= AVG(impervious_surface_pct)
            THEN 'Wetland Loss'
        ELSE 'Urban Runoff'
    END AS dominant_driver
FROM ibadan_flood_data
GROUP BY lga, year
ORDER BY lga, year ASC;

--3. Does extreme rainfall actually translate into worse flood impacts?
-- Compare 24-hour rainfall intensity against flood severity, duration, incidents and population affected.

SELECT lga,
    sum(max_rainfall_24h_mm) as rainfall_24hr,
    SUM(population_affected) AS total_population_affected,
    AVG(flood_severity_1_5) AS avg_severity,
    AVG(flood_duration_hr) AS avg_duration,
	SUM(flood_incidents) as incidents
From ibadan_flood_data
Group by lga
order by rainfall_24hr desc;

--4.How strongly is drainage blockage associated with flood duration?
--Identify whether areas/months with worse drainage blockage experience longer flooding.

select lga, avg(drainage_blockage_pct) AS avg_drainage, AVG(flood_duration_hr) AS avg_duration
from ibadan_flood_data
group by lga
order by avg_drainage desc;

-- Where should flood-prevention investment be prioritised?
-- Create a priority score combining flood burden, cause severity, drainage condition, encroachment, watershed condition and existing prevention coverage.

SELECT
    lga,
    ROUND(AVG(flood_severity_1_5), 2) AS avg_severity,
    ROUND(AVG(flood_incidents), 2) AS avg_flood_incidents,
    ROUND(AVG(drainage_blockage_pct), 2) AS avg_drainage_blockage,
    ROUND(AVG(floodplain_encroachment_pct), 2) AS avg_encroachment,
    ROUND(AVG(watershed_condition_score_0_100), 2) AS avg_watershed_condition,
    ROUND(AVG(early_warning_coverage_pct), 2) AS avg_warning_coverage
FROM ibadan_flood_data
GROUP BY lga
ORDER BY avg_severity DESC;

-- . Which prevention intervention appears most needed in each LGA?
--Match the dominant cause to an appropriate measure such as drainage upgrades, desilting, waste management, zoning, wetland restoration, green infrastructure or early warning.

select *
from ibadan_flood_data;

SELECT 
    lga,
    AVG(drainage_blockage_pct) AS avg_drainage,
    AVG(waste_blockage_level_pct) AS avg_waste,
    AVG(floodplain_encroachment_pct) AS avg_floodplain,
    AVG(wetland_loss_index_pct) AS avg_wetland_loss,
    AVG(impervious_surface_pct) AS avg_urban_runoff,
    CASE 
        WHEN AVG(drainage_blockage_pct) >= AVG(waste_blockage_level_pct)
        AND AVG(drainage_blockage_pct) >= AVG(floodplain_encroachment_pct)
        AND AVG(drainage_blockage_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(drainage_blockage_pct) >= AVG(impervious_surface_pct)
            THEN 'Drainage Blockage'
        WHEN AVG(waste_blockage_level_pct) >= AVG(floodplain_encroachment_pct)
        AND AVG(waste_blockage_level_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(waste_blockage_level_pct) >= AVG(impervious_surface_pct)
            THEN 'Solid Waste Blockage'
        WHEN AVG(floodplain_encroachment_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(floodplain_encroachment_pct) >= AVG(impervious_surface_pct)
            THEN 'Floodplain Encroachment'
        WHEN AVG(wetland_loss_index_pct) >= AVG(impervious_surface_pct)
            THEN 'Wetland Loss'
        ELSE 'Urban Runoff'
    END AS dominant_cause,
    CASE 
        WHEN AVG(drainage_blockage_pct) >= AVG(waste_blockage_level_pct)
        AND AVG(drainage_blockage_pct) >= AVG(floodplain_encroachment_pct)
        AND AVG(drainage_blockage_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(drainage_blockage_pct) >= AVG(impervious_surface_pct)
            THEN 'Drainage Upgrades and Desilting'
        WHEN AVG(waste_blockage_level_pct) >= AVG(floodplain_encroachment_pct)
        AND AVG(waste_blockage_level_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(waste_blockage_level_pct) >= AVG(impervious_surface_pct)
            THEN 'Waste Management and Regular Desilting'
        WHEN AVG(floodplain_encroachment_pct) >= AVG(wetland_loss_index_pct)
        AND AVG(floodplain_encroachment_pct) >= AVG(impervious_surface_pct)
            THEN 'Zoning Enforcement and Floodplain Regulation'
        WHEN AVG(wetland_loss_index_pct) >= AVG(impervious_surface_pct)
            THEN 'Wetland Restoration and Conservation'
        ELSE 'Green Infrastructure and Early Warning Systems'
    END AS recommended_intervention
FROM ibadan_flood_data
GROUP BY lga
ORDER BY lga;

--7. Is early-warning coverage improving resilience?
-- Compare warning coverage with response time, severity and population affected.

select lga, avg(early_warning_coverage_pct) as early_warning, avg(population_affected) as population, 
avg(emergency_response_time_hr) as response_time, AVG(flood_severity_1_5) as severity
from ibadan_flood_data
group by lga
order by early_warning desc;

---8. How is integrated water resources management performing?
-- Compare LGAs on watershed condition, stakeholder coordination, abstraction pressure, water reuse, groundwater depth and water quality.
select lga, avg(watershed_condition_score_0_100) as watershed, avg(iwrm_stakeholder_coordination_score) as iwrm_score, 
avg(water_reuse_rate_pct)as water_reuse, avg(water_abstraction_pressure_pct) as abs_pressure, avg(groundwater_depth_m)as water_depth,
avg(water_turbidity_ntu) as water_turbidity, avg(e_coli_cfu_100mL) as e_coli_presence
from ibadan_flood_data
group by lga
order by lga;


-- 9 Which LGAs have the greatest combined flood and water-resource risk?
-- Build an IWRM + flood-risk matrix to identify locations where flood management and water-resource management should be planned together.

--10 Is Ibadan becoming more or less resilient over 2023-2026?
-- Track changes in flood impacts alongside drainage work, early-warning coverage, waste collection, zoning compliance, green infrastructure and watershed-condition scores.

SELECT
    year,
    ROUND(AVG(flood_incidents), 2) AS avg_flood_incidents,
    ROUND(AVG(flood_severity_1_5), 2) AS avg_flood_severity,
    ROUND(AVG(population_affected), 2) AS avg_population_affected,

    ROUND(AVG(drainage_desilted_km), 2) AS avg_drainage_desilted_km,
    ROUND(AVG(early_warning_coverage_pct), 2) AS avg_early_warning_coverage,
    ROUND(AVG(waste_collection_coverage_pct), 2) AS avg_waste_collection,
    ROUND(AVG(floodplain_zoning_compliance_pct), 2) AS avg_zoning_compliance,
    ROUND(AVG(green_infrastructure_area_ha), 2) AS avg_green_infrastructure,
    ROUND(AVG(watershed_condition_score_0_100), 2) AS avg_watershed_condition

FROM ibadan_flood_data
GROUP BY year
ORDER BY year;

