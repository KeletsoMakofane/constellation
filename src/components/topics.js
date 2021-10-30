const TopicRestriction = (topicChosen) => {

            switch (topicChosen) {
            case "race":
                return "(p.race = 'TRUE')";

            case "racism":
                return "(p.racism = 'TRUE')";


            case "covid":
                return "(p.covid = 'TRUE')";

            case "race_covid":
                return "(p.race = 'TRUE' AND p.covid = 'TRUE')";


            case "racism_covid":
                return "(p.racism = 'TRUE' AND p.covid = 'TRUE')";

                default:
                return "(p.race = 'TRUE' OR p.racism = 'TRUE' OR p.covid = 'TRUE')";
        }
}


export default TopicRestriction;