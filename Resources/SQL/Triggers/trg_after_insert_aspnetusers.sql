CREATE OR REPLACE FUNCTION public.fn_create_ava_user_from_aspnet()
RETURNS trigger AS
$$
DECLARE
    -- travel policy mapped details
    tpm_client_code TEXT := NULL;
    tpm_clientid INT := NULL;
    tpm_default_travel_policyid TEXT := NULL;
    tpm_policy_name TEXT := NULL;

    -- default values
    -- 🚨 causes every insert to have "Id" = 0
    --def_usersyspref_id INT := 0;
    def_usersyspref_is_active BOOLEAN := TRUE;
    def_usersyspref_email TEXT;
    def_usersyspref_firstname TEXT := '';
    def_usersyspref_lastname TEXT := '';
    def_usersyspref_middlename TEXT;

    -- user specified details
    usr_usersyspref_origin_location_code TEXT;
   
    -- flight particulars (travel policy mapped otherwise)
    flight_default_flight_seating TEXT := 'ECONOMY';
    flight_max_flight_seating TEXT := 'FIRST';
    flight_included_airlines TEXT := NULL;
    flight_exluded_airlines TEXT := NULL;
    flight_cabin_class_coverage TEXT := 'MOST_SEGMENTS';
    flight_nonstop_flights BOOLEAN := FALSE;

    -- financial details
    fin_default_currency TEXT := 'AUD';
    fin_max_flight_price INT := 0;

    -- meta
    meta_max_results INT := 20;

    -- times for bookings (travel policy mapped)
    tpm_flight_booking_time_available_from TEXT := NULL;
    tpm_flight_booking_time_available_to TEXT := NULL;

    -- business booking rules (travel policy mapped)
    tpm_enable_saturday_flight_bookings BOOLEAN := TRUE;
    tpm_enable_sunday_flight_bookings BOOLEAN := TRUE;
    tpm_default_calendar_days_in_advance_for_flight_booking INT := NULL;

    -- user lookup values
    usr_aspnet_userid TEXT;
    usr_normalized_email TEXT;
    usr_normalized_domain TEXT;

BEGIN
    -- Step 1: Extract required values from the new user
    usr_aspnet_userid := NEW."Id";
    usr_normalized_email := NEW."NormalizedEmail";
    usr_normalized_domain := split_part(usr_normalized_email, '@', 2);
    def_usersyspref_email := usr_normalized_email;

    -- Step 2: Lookup domain in AvaClientSupportedDomains
    SELECT "ClientCode", "AvaClientId"
    INTO tpm_client_code, tpm_clientid
    FROM public."AvaClientSupportedDomains"
    WHERE "SupportedEmailDomain" = usr_normalized_domain
    LIMIT 1;

    -- Step 3: If match was found, lookup client and get DefaultTravelPolicyId
    IF FOUND THEN
        SELECT "DefaultTravelPolicyId"
        INTO tpm_default_travel_policyid
        FROM public."AvaClients"
        WHERE "Id" = tpm_clientid
        LIMIT 1;
    END IF;

    -- Step 4: If travel policy found, map its values into variables
    IF tpm_default_travel_policyid IS NOT NULL THEN
        SELECT
            "PolicyName",
            "DefaultCurrencyCode",
            "MaxFlightPrice",
            "DefaultFlightSeating",
            "MaxFlightSeating",
            "IncludedAirlineCodes",
            "ExcludedAirlineCodes",
            "CabinClassCoverage",
            "NonStopFlight",
            "FlightBookingTimeAvailableFrom",
            "FlightBookingTimeAvailableTo",
            "EnableSaturdayFlightBookings",
            "EnableSundayFlightBookings",
            "DefaultCalendarDaysInAdvanceForFlightBooking"
        INTO
            tpm_policy_name,
            fin_default_currency,
            fin_max_flight_price,
            flight_default_flight_seating,
            flight_max_flight_seating,
            flight_included_airlines,
            flight_exluded_airlines,
            flight_cabin_class_coverage,
            flight_nonstop_flights,
            tpm_flight_booking_time_available_from,
            tpm_flight_booking_time_available_to,
            tpm_enable_saturday_flight_bookings,
            tpm_enable_sunday_flight_bookings,
            tpm_default_calendar_days_in_advance_for_flight_booking
        FROM public."TravelPolicies"
        WHERE "Id" = tpm_default_travel_policyid
        LIMIT 1;
    END IF;

    -- Step 5: Insert new record into AvaUserSysPreferences, avoid duplicates
    IF NOT EXISTS (
        SELECT 1 FROM public."AvaUserSysPreferences"
        WHERE lower("Email") = lower(def_usersyspref_email)
    ) THEN
        INSERT INTO public."AvaUserSysPreferences" (
            -- "Id",
            "AspNetUsersId",
            "IsActive",
            "Email",
            "FirstName",
            "MiddleName",
            "LastName",
            "OriginLocationCode",
            "DefaultFlightSeating",
            "MaxFlightSeating",
            "IncludedAirlineCodes",
            "ExcludedAirlineCodes",
            "CabinClassCoverage",
            "NonStopFlight",
            "DefaultCurrencyCode",
            "MaxFlightPrice",
            "MaxResults",
            "FlightBookingTimeAvailableFrom",
            "FlightBookingTimeAvailableTo",
            "EnableSaturdayFlightBookings",
            "EnableSundayFlightBookings",
            "DefaultCalendarDaysInAdvanceForFlightBooking",
            "TravelPolicyName",
            "TravelPolicyId",
            "AvaClientId",
            "ClientId"
        )
        VALUES (
            -- def_usersyspref_id,
            usr_aspnet_userid,
            def_usersyspref_is_active,
            lower(def_usersyspref_email),
            def_usersyspref_firstname,
            def_usersyspref_middlename,
            def_usersyspref_lastname,
            usr_usersyspref_origin_location_code,
            flight_default_flight_seating,
            flight_max_flight_seating,
            flight_included_airlines,
            flight_exluded_airlines,
            flight_cabin_class_coverage,
            flight_nonstop_flights,
            fin_default_currency,
            fin_max_flight_price,
            meta_max_results,
            tpm_flight_booking_time_available_from,
            tpm_flight_booking_time_available_to,
            tpm_enable_saturday_flight_bookings,
            tpm_enable_sunday_flight_bookings,
            tpm_default_calendar_days_in_advance_for_flight_booking,
            tpm_policy_name,
            tpm_default_travel_policyid,
            tpm_clientid,
            tpm_client_code
        );
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

-- Optional: Drop existing trigger if redeploying
DROP TRIGGER IF EXISTS trg_after_insert_create_user_syspref ON public."AspNetUsers";

-- Create the trigger that links to the function
CREATE TRIGGER trg_after_insert_create_user_syspref
AFTER INSERT ON public."AspNetUsers"
FOR EACH ROW
EXECUTE FUNCTION public.fn_create_ava_user_from_aspnet();
